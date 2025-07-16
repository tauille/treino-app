import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class NetworkDetector {
  static final NetworkDetector _instance = NetworkDetector._internal();
  factory NetworkDetector() => _instance;
  NetworkDetector._internal();

  // ===== CONFIGURAÇÃO =====
  
  /// Porta do Laravel
  static const int _port = 8000;
  
  /// Timeout otimizado para diferentes redes
  static const Duration _testTimeout = Duration(seconds: 5);
  static const Duration _longTimeout = Duration(seconds: 10);
  
  /// Cache da última URL que funcionou
  static const String _cacheKey = 'last_working_api_url';
  
  /// IPs comuns de roteadores para fallback
  static const List<String> _commonRouterIPs = [
    '192.168.1.1', '192.168.0.1', '192.168.18.1', '10.0.0.1', '172.16.0.1'
  ];
  
  // ===== ESTADO =====
  
  String? _currentWorkingIP;
  String? _currentBaseUrl;
  bool _isDetecting = false;
  List<String> _lastDetectedRange = [];

  // ===== GETTERS =====
  
  String? get currentIP => _currentWorkingIP;
  String? get currentBaseUrl => _currentBaseUrl;
  bool get isDetecting => _isDetecting;
  List<String> get lastDetectedRange => List.unmodifiable(_lastDetectedRange);

  // ===== MÉTODOS PRINCIPAIS =====

  /// 🔍 Detectar automaticamente qual IP está funcionando
  Future<String> detectWorkingAPI() async {
    if (_isDetecting) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _currentBaseUrl ?? _getDefaultUrl();
    }

    _isDetecting = true;

    try {
      print('🔍 === INICIANDO DETECÇÃO AUTOMÁTICA ===');

      // 1. Tentar cache primeiro
      final cachedUrl = await _tryCache();
      if (cachedUrl != null) {
        _setWorkingUrl(cachedUrl);
        return cachedUrl;
      }

      // 2. Detectar IP local do dispositivo
      final deviceIP = await _getDeviceLocalIP();
      if (deviceIP != null) {
        print('📱 IP do dispositivo: $deviceIP');
        
        // 3. Gerar lista de IPs para testar baseada na rede local
        final ipRange = _generateIPRange(deviceIP);
        print('🌐 Rede detectada: ${_getNetworkInfo(deviceIP)}');
        print('🎯 Testando ${ipRange.length} IPs possíveis...');
        
        // 4. Testar IPs da rede local
        final workingUrl = await _testIPRange(ipRange);
        if (workingUrl != null) {
          _setWorkingUrl(workingUrl);
          await _saveToCache(workingUrl);
          return workingUrl;
        }
      }

      // 5. Fallback: IPs comuns hardcoded
      print('⚠️ Detecção automática falhou, testando IPs comuns...');
      final fallbackUrl = await _testCommonIPs();
      if (fallbackUrl != null) {
        _setWorkingUrl(fallbackUrl);
        await _saveToCache(fallbackUrl);
        return fallbackUrl;
      }

      // 6. Último recurso: IP padrão local
      print('❌ Todos os testes falharam, usando localhost');
      final defaultUrl = _getDefaultUrl();
      _setWorkingUrl(defaultUrl);
      return defaultUrl;

    } catch (e) {
      print('❌ Erro na detecção: $e');
      final defaultUrl = _getDefaultUrl();
      _setWorkingUrl(defaultUrl);
      return defaultUrl;
    } finally {
      _isDetecting = false;
    }
  }

  /// 🔄 Forçar nova detecção (limpar cache)
  Future<String> forceDetection() async {
    print('🔄 === FORÇANDO NOVA DETECÇÃO ===');
    await _clearCache();
    _currentWorkingIP = null;
    _currentBaseUrl = null;
    _lastDetectedRange.clear();
    return await detectWorkingAPI();
  }

  /// ✅ Testar se a API atual ainda está funcionando
  Future<bool> testCurrentAPI() async {
    if (_currentBaseUrl == null) return false;
    
    final ip = _extractIPFromUrl(_currentBaseUrl!);
    return await _testSingleIP(ip);
  }

  // ===== MÉTODOS PRIVADOS - DETECÇÃO DE REDE =====

  /// 📱 Obter IP local do dispositivo
  Future<String?> _getDeviceLocalIP() async {
    try {
      // Método 1: Conectar em servidor externo para descobrir IP local
      final socket = await Socket.connect('8.8.8.8', 80, timeout: const Duration(seconds: 3));
      final deviceIP = socket.address.address;
      socket.destroy();
      
      print('📡 IP detectado via socket: $deviceIP');
      return deviceIP;
      
    } catch (e) {
      print('⚠️ Falha na detecção via socket: $e');
      
      try {
        // Método 2: Listar interfaces de rede
        final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
        
        for (final interface in interfaces) {
          for (final addr in interface.addresses) {
            final ip = addr.address;
            
            // Filtrar apenas IPs de redes locais
            if (_isLocalIP(ip) && !ip.startsWith('127.')) {
              print('🔌 IP detectado via interface ${interface.name}: $ip');
              return ip;
            }
          }
        }
      } catch (e2) {
        print('⚠️ Falha na detecção via interface: $e2');
      }
    }
    
    return null;
  }

  /// 🏠 Verificar se IP é de rede local
  bool _isLocalIP(String ip) {
    return ip.startsWith('192.168.') || 
           ip.startsWith('10.') || 
           (ip.startsWith('172.') && _isInRange172(ip));
  }

  /// 🔍 Verificar se IP está na faixa 172.16.0.0 - 172.31.255.255
  bool _isInRange172(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    try {
      final secondOctet = int.parse(parts[1]);
      return secondOctet >= 16 && secondOctet <= 31;
    } catch (e) {
      return false;
    }
  }

  /// 🌐 Gerar lista de IPs para testar baseada no IP do dispositivo
  List<String> _generateIPRange(String deviceIP) {
    final ipList = <String>[];
    final parts = deviceIP.split('.');
    
    if (parts.length != 4) return [];
    
    final baseNetwork = '${parts[0]}.${parts[1]}.${parts[2]}';
    _lastDetectedRange = ['$baseNetwork.0/24'];
    
    // IPs mais prováveis primeiro (hosts comuns de desenvolvimento)
    final priorityIPs = [
      '$baseNetwork.100', // IP comum para dev
      '$baseNetwork.1',   // Gateway
      '$baseNetwork.2',   // Primeiro host
      '$baseNetwork.10',  // IP comum
      '$baseNetwork.101', // Sequência de .100
      '$baseNetwork.50',  // Meio da faixa
    ];
    
    // Adicionar IPs prioritários
    ipList.addAll(priorityIPs);
    
    // Adicionar IPs do final da faixa (mais comuns para hosts)
    for (int i = 200; i <= 254; i++) {
      final ip = '$baseNetwork.$i';
      if (!ipList.contains(ip)) {
        ipList.add(ip);
      }
    }
    
    // Adicionar resto da faixa (início)
    for (int i = 3; i <= 199; i++) {
      final ip = '$baseNetwork.$i';
      if (!ipList.contains(ip)) {
        ipList.add(ip);
      }
    }
    
    return ipList;
  }

  /// 🎯 Obter informações legíveis da rede
  String _getNetworkInfo(String deviceIP) {
    final parts = deviceIP.split('.');
    if (parts.length != 4) return 'Desconhecida';
    
    final firstOctet = int.tryParse(parts[0]) ?? 0;
    final secondOctet = int.tryParse(parts[1]) ?? 0;
    
    if (firstOctet == 192 && secondOctet == 168) {
      return 'Rede doméstica/escritório (192.168.x.x)';
    } else if (firstOctet == 10) {
      return 'Rede corporativa (10.x.x.x)';
    } else if (firstOctet == 172 && secondOctet >= 16 && secondOctet <= 31) {
      return 'Rede corporativa (172.16-31.x.x)';
    } else {
      return 'Rede personalizada ($firstOctet.$secondOctet.x.x)';
    }
  }

  // ===== MÉTODOS PRIVADOS - TESTES =====

  /// 🧪 Testar faixa de IPs
  Future<String?> _testIPRange(List<String> ipRange) async {
    // Testar IPs prioritários primeiro (primeiros 10)
    final priorityIPs = ipRange.take(10).toList();
    final remainingIPs = ipRange.skip(10).toList();
    
    print('🎯 Testando ${priorityIPs.length} IPs prioritários...');
    final priorityResult = await _testIPList(priorityIPs);
    if (priorityResult != null) return priorityResult;
    
    print('🔄 Testando ${remainingIPs.length} IPs restantes...');
    return await _testIPList(remainingIPs);
  }

  /// 📝 Testar lista de IPs
  Future<String?> _testIPList(List<String> ipList) async {
    for (int i = 0; i < ipList.length; i++) {
      final ip = ipList[i];
      print('🧪 [${i + 1}/${ipList.length}] Testando: $ip');
      
      try {
        final isWorking = await _testSingleIP(ip);
        
        if (isWorking) {
          final workingUrl = 'http://$ip:$_port/api';
          print('✅ ENCONTRADO! URL: $workingUrl');
          return workingUrl;
        }
        
        // Pausa pequena entre testes para não sobrecarregar a rede
        if (i % 5 == 0 && i > 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
      } catch (e) {
        print('❌ Erro testando $ip: ${e.toString().split(':').first}');
        continue;
      }
    }
    
    return null;
  }

  /// 🔧 Testar IPs comuns (fallback)
  Future<String?> _testCommonIPs() async {
    final commonIPs = [
      '192.168.1.100', '192.168.1.1', '192.168.1.2',
      '192.168.0.100', '192.168.0.1', '192.168.0.2',
      '192.168.18.48', // IP que estava hardcoded
      '10.125.135.38', // IP que estava hardcoded
      '10.0.0.100', '10.0.0.1',
      '172.16.0.100', '172.16.0.1',
    ];
    
    print('🔄 Testando ${commonIPs.length} IPs comuns...');
    return await _testIPList(commonIPs);
  }

  /// 🔍 Testar se um IP específico está funcionando
  Future<bool> _testSingleIP(String ip) async {
    try {
      final url = 'http://$ip:$_port/api/status';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_testTimeout);
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final isValid = data['status'] == 'online' || 
                         data['message'] != null ||
                         data.isNotEmpty;
          
          if (isValid) {
            print('  ✅ $ip: Laravel respondeu corretamente');
          }
          
          return isValid;
        } catch (e) {
          // Se conectou mas JSON inválido, ainda considerar funcionando
          print('  ⚠️ $ip: Conectou mas resposta não é JSON válido');
          return true;
        }
      } else {
        print('  ❌ $ip: Status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Timeout, connection refused, etc.
      final errorMsg = e.toString();
      if (errorMsg.contains('timeout')) {
        print('  ⏱️ $ip: Timeout (${_testTimeout.inSeconds}s)');
      } else if (errorMsg.contains('refused')) {
        print('  🚫 $ip: Conexão recusada');
      } else {
        print('  ❌ $ip: ${errorMsg.split(': ').last}');
      }
      return false;
    }
  }

  // ===== MÉTODOS PRIVADOS - CACHE =====

  /// 💾 Tentar carregar do cache
  Future<String?> _tryCache() async {
    try {
      final storage = StorageService();
      final cachedUrl = await storage.getString(_cacheKey);
      
      if (cachedUrl != null) {
        print('📦 URL no cache: $cachedUrl');
        
        // Testar se ainda funciona
        final ip = _extractIPFromUrl(cachedUrl);
        final stillWorks = await _testSingleIP(ip);
        
        if (stillWorks) {
          print('✅ Cache válido: $cachedUrl');
          return cachedUrl;
        } else {
          print('❌ Cache inválido, limpando...');
          await _clearCache();
        }
      }
    } catch (e) {
      print('⚠️ Erro ao ler cache: $e');
    }
    
    return null;
  }

  /// 💾 Salvar URL funcionando no cache
  Future<void> _saveToCache(String url) async {
    try {
      final storage = StorageService();
      await storage.saveString(_cacheKey, url);
      print('💾 Cache salvo: $url');
    } catch (e) {
      print('❌ Erro ao salvar cache: $e');
    }
  }

  /// 🗑️ Limpar cache
  Future<void> _clearCache() async {
    try {
      final storage = StorageService();
      await storage.remove(_cacheKey);
      print('🗑️ Cache limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  // ===== MÉTODOS UTILITÁRIOS =====

  /// 🔧 Definir URL que está funcionando
  void _setWorkingUrl(String url) {
    _currentBaseUrl = url;
    _currentWorkingIP = _extractIPFromUrl(url);
    
    print('🌐 === URL ATIVA ===');
    print('📡 IP: $_currentWorkingIP');
    print('🔗 URL: $url');
    print('==================');
  }

  /// 🔍 Extrair IP de uma URL
  String _extractIPFromUrl(String url) {
    final uri = Uri.parse(url);
    return uri.host;
  }

  /// 🏠 URL padrão (localhost)
  String _getDefaultUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port/api'; // Android emulator
    } else {
      return 'http://127.0.0.1:$_port/api'; // iOS simulator
    }
  }

  // ===== MÉTODOS PÚBLICOS UTILITÁRIOS =====

  /// 📊 Obter informações completas da rede atual
  Map<String, dynamic> getNetworkInfo() {
    return {
      'currentIP': _currentWorkingIP,
      'currentBaseUrl': _currentBaseUrl,
      'isDetecting': _isDetecting,
      'lastDetectedRange': _lastDetectedRange,
      'port': _port,
      'timeout': _testTimeout.inSeconds,
      'cacheKey': _cacheKey,
      'platform': Platform.operatingSystem,
    };
  }

  /// 🎯 Testar IP específico manualmente
  Future<bool> testSpecificIP(String ip) async {
    print('🎯 Teste manual: $ip');
    return await _testSingleIP(ip);
  }

  /// ➕ Testar e usar IP específico (para debug)
  Future<bool> forceSpecificIP(String ip) async {
    print('🎯 Forçando IP específico: $ip');
    final works = await _testSingleIP(ip);
    
    if (works) {
      final url = 'http://$ip:$_port/api';
      _setWorkingUrl(url);
      await _saveToCache(url);
      print('✅ IP forçado com sucesso: $url');
      return true;
    } else {
      print('❌ IP não está funcionando: $ip');
      return false;
    }
  }

  /// 🔄 Reset completo
  void reset() {
    print('🔄 === RESET COMPLETO ===');
    _currentWorkingIP = null;
    _currentBaseUrl = null;
    _isDetecting = false;
    _lastDetectedRange.clear();
  }

  /// 📈 Obter estatísticas da última detecção
  Map<String, dynamic> getDetectionStats() {
    return {
      'hasWorkingIP': _currentWorkingIP != null,
      'workingIP': _currentWorkingIP,
      'networkRange': _lastDetectedRange,
      'isCurrentlyDetecting': _isDetecting,
      'platform': Platform.operatingSystem,
      'defaultUrl': _getDefaultUrl(),
    };
  }

  /// 🔍 Scan completo da rede (modo debug)
  Future<List<String>> scanNetworkRange(String deviceIP) async {
    print('🔍 === SCAN COMPLETO DA REDE ===');
    print('📱 IP base: $deviceIP');
    
    final workingIPs = <String>[];
    final ipRange = _generateIPRange(deviceIP);
    
    print('🎯 Scanning ${ipRange.length} IPs...');
    
    for (int i = 0; i < ipRange.length; i++) {
      final ip = ipRange[i];
      final works = await _testSingleIP(ip);
      
      if (works) {
        workingIPs.add(ip);
        print('✅ ENCONTRADO: $ip');
      }
      
      if (i % 10 == 0) {
        print('📊 Progresso: ${i + 1}/${ipRange.length}');
      }
    }
    
    print('🏁 Scan completo: ${workingIPs.length} IPs funcionando');
    return workingIPs;
  }
}