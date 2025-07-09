// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/api_response_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  // ========================================
  // PROPRIEDADES PRIVADAS
  // ========================================
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;

  // Serviços
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // ========================================
  // GETTERS PÚBLICOS
  // ========================================
  
  AuthState get state => _state;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  
  // Estados computados
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null && _token != null;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;
  bool get hasError => _state == AuthState.error;
  bool get isInitial => _state == AuthState.initial;
  
  // Propriedades do usuário
  bool get hasPremium => _user?.hasActivePremium ?? false;
  bool get hasActiveTrial => _user?.hasActiveTrial ?? false;
  bool get canUseAdvancedFeatures => _user?.canUseAdvancedFeatures ?? false;
  String get accountType => _user?.accountType ?? 'Gratuita';
  String get displayName => _user?.displayName ?? 'Usuário';

  // ========================================
  // INICIALIZAÇÃO
  // ========================================
  
  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      print('🔄 Inicializando AuthProvider...');
      _setState(AuthState.loading);
      
      // Inicializar storage
      await _storageService.ensureInitialized();
      
      // Verificar se há dados salvos
      await _checkStoredAuth();
      
      print('✅ AuthProvider inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar AuthProvider: $e');
      _setError('Erro ao inicializar autenticação');
    }
  }

  Future<void> _checkStoredAuth() async {
    try {
      // Buscar token e dados do usuário salvos
      final storedToken = await _storageService.getToken();
      final userData = await _storageService.getUserData();
      
      if (storedToken != null && userData != null) {
        // Tentar restaurar sessão
        _token = storedToken;
        _user = User.fromStorageData(userData);
        
        // Verificar se o token ainda é válido (opcional)
        final isValid = await _authService.isAuthenticated();
        
        if (isValid) {
          print('✅ Sessão restaurada: ${_user!.name}');
          _setState(AuthState.authenticated);
        } else {
          print('⚠️ Token inválido, fazendo logout');
          await _clearAuth();
        }
      } else {
        print('📝 Nenhuma sessão encontrada');
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      print('❌ Erro ao verificar auth armazenado: $e');
      await _clearAuth();
    }
  }

  // ========================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ========================================

  /// Login do usuário
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Iniciando login para: $email');
      _setLoading(true);
      _clearError();
      
      final response = await _authService.login(
        email: email,
        password: password,
      );
      
      if (response.success && response.data != null) {
        // Salvar dados da resposta
        await _saveAuthData(response.data!);
        
        print('✅ Login bem-sucedido: ${response.data!.name}');
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
      
    } catch (e) {
      print('❌ Erro no login: $e');
      _setError('Erro ao fazer login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registro de novo usuário
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('👤 Iniciando registro para: $email');
      _setLoading(true);
      _clearError();
      
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      if (response.success && response.data != null) {
        // Salvar dados da resposta
        await _saveAuthData(response.data!);
        
        print('✅ Registro bem-sucedido: ${response.data!.name}');
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
      
    } catch (e) {
      print('❌ Erro no registro: $e');
      _setError('Erro ao criar conta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout do usuário
  Future<void> logout() async {
    try {
      print('🚪 Fazendo logout...');
      _setLoading(true);
      
      // Tentar fazer logout no servidor
      await _authService.logout();
      
      // Limpar dados locais
      await _clearAuth();
      
      print('✅ Logout realizado');
    } catch (e) {
      print('❌ Erro no logout: $e');
      // Mesmo com erro, limpar dados locais
      await _clearAuth();
    } finally {
      _setLoading(false);
    }
  }

  /// Atualizar dados do usuário
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      print('👤 Atualizando perfil...');
      _setLoading(true);
      _clearError();
      
      // Simular chamada para API (implementar quando tiver endpoint)
      await Future.delayed(const Duration(seconds: 1));
      
      // Por enquanto, atualizar localmente
      if (_user != null) {
        _user = _user!.copyWith(name: name, email: email);
        await _updateStoredUser(_user!);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');
      _setError('Erro ao atualizar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Alterar senha
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      print('🔒 Alterando senha...');
      _setLoading(true);
      _clearError();
      
      if (newPassword != confirmPassword) {
        _setError('Nova senha e confirmação não conferem');
        return false;
      }
      
      // Simular chamada para API (implementar quando tiver endpoint)
      await Future.delayed(const Duration(seconds: 1));
      
      // Por enquanto, simular sucesso
      print('✅ Senha alterada');
      return true;
      
    } catch (e) {
      print('❌ Erro ao alterar senha: $e');
      _setError('Erro ao alterar senha: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh dos dados do usuário
  Future<void> refreshUser() async {
    try {
      if (!isAuthenticated) return;
      
      print('🔄 Atualizando dados do usuário...');
      
      // Simular busca de dados atualizados (implementar quando tiver endpoint)
      await Future.delayed(const Duration(seconds: 1));
      
      print('✅ Dados do usuário atualizados');
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao atualizar dados: $e');
    }
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AuthState.error);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (_state == AuthState.error) {
        _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
      }
    }
  }

  Future<void> _saveAuthData(User user) async {
    try {
      // Obter token do serviço
      _token = await _authService.getCurrentToken();
      _user = user;
      
      // Não precisa salvar novamente, o AuthService já salvou
      print('💾 Dados de autenticação salvos');
    } catch (e) {
      print('❌ Erro ao salvar dados de auth: $e');
      throw e;
    }
  }

  Future<void> _updateStoredUser(User user) async {
    try {
      await _storageService.saveUserData(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        isPremium: user.isPremium,
        trialStartedAt: user.trialStartedAt,
        premiumExpiresAt: user.premiumExpiresAt,
        isEmailVerified: user.isEmailVerified,
        emailVerifiedAt: user.emailVerifiedAt,
        createdAt: user.createdAt,
      );
    } catch (e) {
      print('❌ Erro ao atualizar usuário armazenado: $e');
    }
  }

  Future<void> _clearAuth() async {
    try {
      // Limpar dados do storage
      await _storageService.clearAuthData();
      
      // Limpar variáveis locais
      _user = null;
      _token = null;
      _errorMessage = null;
      
      _setState(AuthState.unauthenticated);
    } catch (e) {
      print('❌ Erro ao limpar auth: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  /// Verificar se feature está disponível
  bool canUseFeature(String featureName) {
    // Features básicas sempre disponíveis
    const basicFeatures = [
      'basic_workouts',
      'basic_exercises',
      'view_progress',
    ];
    
    if (basicFeatures.contains(featureName)) {
      return true;
    }
    
    // Features premium
    return canUseAdvancedFeatures;
  }

  /// Obter headers para requisições autenticadas
  Map<String, String> get authHeaders {
    final baseHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      baseHeaders['Authorization'] = 'Bearer $_token';
    }
    
    return baseHeaders;
  }

  /// Debug: Imprimir informações de auth
  void printDebugInfo() {
    print('🔍 AuthProvider Debug Info:');
    print('   State: $_state');
    print('   Is Authenticated: $isAuthenticated');
    print('   User: ${_user?.name ?? 'null'} (${_user?.email ?? 'no email'})');
    print('   Token: ${_token != null ? 'Present (${_token!.length} chars)' : 'null'}');
    print('   Premium: $hasPremium');
    print('   Trial: $hasActiveTrial');
    print('   Account Type: $accountType');
    print('   Error: $_errorMessage');
  }

  // ========================================
  // MÉTODOS PARA TRIAL/PREMIUM
  // ========================================

  /// Iniciar trial
  Future<bool> startTrial() async {
    try {
      if (_user?.canStartTrial != true) return false;
      
      _user = _user!.startTrial();
      await _updateStoredUser(_user!);
      notifyListeners();
      
      print('🎯 Trial iniciado para ${_user!.name}');
      return true;
    } catch (e) {
      print('❌ Erro ao iniciar trial: $e');
      return false;
    }
  }

  /// Upgrade para premium
  Future<bool> upgradeToPremium({DateTime? expiresAt}) async {
    try {
      if (_user == null) return false;
      
      _user = _user!.upgradeToPremium(expiresAt: expiresAt);
      await _updateStoredUser(_user!);
      notifyListeners();
      
      print('💎 Upgrade para premium: ${_user!.name}');
      return true;
    } catch (e) {
      print('❌ Erro ao fazer upgrade: $e');
      return false;
    }
  }
}