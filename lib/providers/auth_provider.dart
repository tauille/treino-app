import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/google_auth_service.dart';
import '../models/api_response_model.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  // 🔄 INICIALIZAR PROVIDER
  Future<void> initialize() async {
    try {
      print('🔄 Inicializando AuthProvider...');
      _setState(AuthState.loading);

      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await AuthService.getUser();
        if (user != null) {
          _user = user;
          _setState(AuthState.authenticated);
          print('✅ Usuário já estava logado: ${user.name}');
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
        print('🔍 Usuário não está logado');
      }
    } catch (e) {
      print('❌ Erro ao inicializar AuthProvider: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  // 🔐 REGISTRO
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('🔐 Tentando registrar: $email');
      _setLoading(true);
      _clearError();

      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        print('✅ Registro bem-sucedido!');
        return true;
      } else {
        _setError(response.message);
        print('❌ Erro no registro: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado durante o registro');
      print('❌ Erro inesperado no registro: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🔑 LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 Tentando fazer login: $email');
      _setLoading(true);
      _clearError();

      final response = await AuthService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        print('✅ Login bem-sucedido!');
        return true;
      } else {
        _setError(response.message);
        print('❌ Erro no login: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado durante o login');
      print('❌ Erro inesperado no login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🔑 LOGIN COM GOOGLE
  Future<bool> loginWithGoogle() async {
    try {
      print('🔑 Tentando fazer login com Google...');
      _setLoading(true);
      _clearError();

      final response = await GoogleAuthService.signInWithGoogle();

      if (response.success && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        print('✅ Login com Google bem-sucedido!');
        return true;
      } else {
        _setError(response.message);
        print('❌ Erro no login com Google: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado durante o login com Google');
      print('❌ Erro inesperado no login com Google: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    try {
      print('🚪 Fazendo logout...');
      _setLoading(true);

      // Logout da API Laravel
      await AuthService.logout();
      
      // Logout do Google (se estiver logado)
      await GoogleAuthService.signOut();
      
      _user = null;
      _setState(AuthState.unauthenticated);
      _clearError();
      
      print('✅ Logout realizado com sucesso!');
    } catch (e) {
      print('❌ Erro no logout: $e');
      // Mesmo com erro, limpar dados locais
      _user = null;
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // 🔄 ATUALIZAR DADOS DO USUÁRIO
  Future<void> refreshUser() async {
    try {
      print('🔄 Atualizando dados do usuário...');
      
      final response = await AuthService.getMe();
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        print('✅ Dados do usuário atualizados!');
      } else {
        print('⚠️ Falha ao atualizar dados do usuário');
      }
    } catch (e) {
      print('❌ Erro ao atualizar dados do usuário: $e');
    }
  }

  // 🔄 ATUALIZAR PERFIL
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      print('🔄 Atualizando perfil...');
      _setLoading(true);
      _clearError();

      final response = await AuthService.updateProfile(
        name: name,
        email: email,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        print('✅ Perfil atualizado com sucesso!');
        return true;
      } else {
        _setError(response.message);
        print('❌ Erro ao atualizar perfil: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado ao atualizar perfil');
      print('❌ Erro inesperado ao atualizar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🔐 ALTERAR SENHA
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      print('🔐 Alterando senha...');
      _setLoading(true);
      _clearError();

      final response = await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success) {
        // Logout automático após alterar senha
        _user = null;
        _setState(AuthState.unauthenticated);
        print('✅ Senha alterada com sucesso! Faça login novamente.');
        return true;
      } else {
        _setError(response.message);
        print('❌ Erro ao alterar senha: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado ao alterar senha');
      print('❌ Erro inesperado ao alterar senha: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🎯 VERIFICAR PREMIUM/TRIAL
  bool get hasPremium => _user?.isPremium ?? false;
  bool get hasActiveTrial => _user?.hasActiveTrial ?? false;
  bool get canUseAdvancedFeatures => hasPremium || hasActiveTrial;
  int get trialDaysRemaining => _user?.trialDaysRemaining ?? 0;

  // 📊 ESTATÍSTICAS DO USUÁRIO
  String get memberSince => _user?.memberSince ?? '';
  String get accountType => _user?.accountType ?? 'Gratuita';

  // 🛠️ MÉTODOS PRIVADOS
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }

  // 🔄 LIMPAR TODOS OS DADOS
  void clear() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    _setState(AuthState.unauthenticated);
  }

  // 📱 MÉTODO PARA DEBUG
  void printDebugInfo() {
    print('🐛 AuthProvider Debug Info:');
    print('   Estado: $_state');
    print('   Usuário: ${_user?.name ?? 'null'}');
    print('   Email: ${_user?.email ?? 'null'}');
    print('   Premium: $hasPremium');
    print('   Trial Ativo: $hasActiveTrial');
    print('   Dias Trial: $trialDaysRemaining');
    print('   Erro: $_errorMessage');
    print('   Carregando: $_isLoading');
  }
}