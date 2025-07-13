import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class NetworkDetector {
  static final NetworkDetector _instance = NetworkDetector._internal();
  factory NetworkDetector() => _instance;
  NetworkDetector._internal();

  // ===== CONFIGURAÇÃO DOS IPs =====
  
  /// Lista de IPs/redes onde você trabalha
  static const List<String> _possibleIPs = [
    '192.168.18.48',    // Rede atual
    '10.125.135.38',    // Rede anterior  
    '192.168.1.100',    // Casa/Escritório 1
    '192.168.0.100',    // Casa/Escritório 2
    '10.0.0.100',       // Outras redes possíveis
    '172.16.0.100',     // Rede corporativa
  ];

  /// Porta do Laravel
  static const int _port = 8000;
  
  /// Timeout para teste de conexão
  static const Duration _testTimeout = Duration(seconds: 3);
  
  /// Cache da última URL que funcionou
  static const String _cacheKey = 'last_working_api_url';
  
  // ===== ESTADO =====
  
  String? _currentWorkingIP;
  String? _currentBaseUrl;
  bool _isDetecting = false;

  // ===== GETTERS =====
  
  String? get currentIP => _currentWorkingIP;
  String? get currentBaseUrl => _currentBaseUrl;
  bool get isDetecting => _isDetecting;

  // ===== MÉTODOS PRINCIPAIS =====

  /// Detectar automaticamente qual IP está funcionando
  Future<String> detectWorkingAPI() async {
    if (_isDetecting) {
      // Se já está detectando, aguarda o resultado atual
      await Future.delayed(const Duration(milliseconds: 100));
      return _currentBaseUrl ?? _getDefaultUrl();
    }

    _isDetecting = true;

    try {
      print('🔍 Detectando rede disponível...');

      // 1. Tentar usar o último IP que funcionou (cache)
      final cachedUrl = await _tryFromCache();
      if (cachedUrl != null) {
        _setWorkingUrl(cachedUrl);
        return cachedUrl;
      }

      // 2. Testar todos os IPs possíveis
      final workingUrl = await _testAllIPs();
      if (workingUrl != null) {
        _setWorkingUrl(workingUrl);
        await _saveToCache(workingUrl);
        return workingUrl;
      }

      // 3. Fallback para IP padrão
      print('⚠️ Nenhuma rede detectada, usando IP padrão');
      final defaultUrl = _getDefaultUrl();
      _setWorkingUrl(defaultUrl);
      return defaultUrl;

    } catch (e) {
      print('❌ Erro na detecção de rede: $e');
      final defaultUrl = _getDefaultUrl();
      _setWorkingUrl(defaultUrl);
      return defaultUrl;
    } finally {
      _isDetecting = false;
    }
  }

  /// Forçar nova detecção (limpar cache)
  Future<String> forceDetection() async {
    print('🔄 Forçando nova detecção de rede...');
    await _clearCache();
    return await detectWorkingAPI();
  }

  /// Testar se a API atual ainda está funcionando
  Future<bool> testCurrentAPI() async {
    if (_currentBaseUrl == null) return false;
    
    return await _testSingleIP(_extractIPFromUrl(_currentBaseUrl!));
  }

  // ===== MÉTODOS PRIVADOS =====

  /// Tentar usar o IP do cache
  Future<String?> _tryFromCache() async {
    try {
      final storage = StorageService();
      final cachedUrl = await storage.getString(_cacheKey);
      
      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        print('📦 Testando URL do cache: $cachedUrl');
        
        final ip = _extractIPFromUrl(cachedUrl);
        final isWorking = await _testSingleIP(ip);
        
        if (isWorking) {
          print('✅ Cache funcionando: $cachedUrl');
          return cachedUrl;
        } else {
          print('❌ Cache não funciona mais, limpando...');
          await _clearCache();
        }
      }
    } catch (e) {
      print('❌ Erro ao testar cache: $e');
    }
    
    return null;
  }

  /// Testar todos os IPs possíveis
  Future<String?> _testAllIPs() async {
    print('🔍 Testando ${_possibleIPs.length} IPs possíveis...');
    
    // Testa todos os IPs em paralelo para ser mais rápido
    final futures = _possibleIPs.map((ip) => _testSingleIPWithResult(ip));
    final results = await Future.wait(futures);
    
    // Encontra o primeiro que funciona
    for (final result in results) {
      if (result != null) {
        print('✅ IP funcionando encontrado: $result');
        return result;
      }
    }
    
    print('❌ Nenhum IP funcionando encontrado');
    return null;
  }

  /// Testar um IP específico e retornar a URL se funcionar
  Future<String?> _testSingleIPWithResult(String ip) async {
    final isWorking = await _testSingleIP(ip);
    if (isWorking) {
      return 'http://$ip:$_port/api';
    }
    return null;
  }

  /// Testar se um IP específico está funcionando
  Future<bool> _testSingleIP(String ip) async {
    try {
      final url = 'http://$ip:$_port/api/status';
      
      if (kDebugMode) {
        print('🧪 Testando: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(_testTimeout);
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final isValid = data['status'] == 'online' || 
                         data['message']?.contains('funcionando') == true;
          
          if (kDebugMode) {
            print(isValid ? '✅ $ip: OK' : '❌ $ip: Resposta inválida');
          }
          
          return isValid;
        } catch (e) {
          if (kDebugMode) {
            print('❌ $ip: JSON inválido');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('❌ $ip: Status ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ $ip: ${e.toString().split(': ').last}');
      }
      return false;
    }
  }

  /// Definir URL que está funcionando
  void _setWorkingUrl(String url) {
    _currentBaseUrl = url;
    _currentWorkingIP = _extractIPFromUrl(url);
    
    print('🌐 URL ativa definida: $url');
  }

  /// Extrair IP de uma URL
  String _extractIPFromUrl(String url) {
    final uri = Uri.parse(url);
    return uri.host;
  }

  /// Obter URL padrão (primeiro IP da lista)
  String _getDefaultUrl() {
    return 'http://${_possibleIPs.first}:$_port/api';
  }

  /// Salvar URL funcionando no cache
  Future<void> _saveToCache(String url) async {
    try {
      final storage = StorageService();
      await storage.saveString(_cacheKey, url);
      print('💾 URL salva no cache: $url');
    } catch (e) {
      print('❌ Erro ao salvar cache: $e');
    }
  }

  /// Limpar cache
  Future<void> _clearCache() async {
    try {
      final storage = StorageService();
      await storage.remove(_cacheKey);
      print('🗑️ Cache de rede limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  // ===== MÉTODOS UTILITÁRIOS =====

  /// Obter informações da rede atual
  Map<String, dynamic> getNetworkInfo() {
    return {
      'currentIP': _currentWorkingIP,
      'currentBaseUrl': _currentBaseUrl,
      'isDetecting': _isDetecting,
      'possibleIPs': _possibleIPs,
      'port': _port,
    };
  }

  /// Adicionar novo IP à lista (temporariamente)
  void addTempIP(String ip) {
    if (!_possibleIPs.contains(ip)) {
      // Cria uma nova lista temporária com o IP adicional
      print('➕ Adicionando IP temporário: $ip');
    }
  }

  /// Obter lista de IPs disponíveis
  List<String> get possibleIPs => List.unmodifiable(_possibleIPs);

  /// Verificar se está usando IP específico
  bool isUsingIP(String ip) {
    return _currentWorkingIP == ip;
  }

  /// Reset completo
  void reset() {
    _currentWorkingIP = null;
    _currentBaseUrl = null;
    _isDetecting = false;
  }
}