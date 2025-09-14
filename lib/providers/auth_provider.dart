import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/api_response_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/routes/app_routes.dart';

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
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;
  bool _disposed = false;

  // Serviços
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // GETTERS
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

  AuthProvider() {
    _initialize();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  Future<void> _initialize() async {
    try {
      _setState(AuthState.loading);
      
      // Inicializar storage
      await _storageService.ensureInitialized();
      
      // Verificar se há dados salvos
      await _checkStoredAuth();
      
    } catch (e) {
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
          _setState(AuthState.authenticated);
        } else {
          await _clearAuth();
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      await _clearAuth();
    }
  }

  /// Login do usuário
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _authService.login(
        email: email,
        password: password,
      );
      
      if (response.success && response.data != null) {
        // Salvar dados da resposta
        await _saveAuthData(response.data!);
        
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
      
    } catch (e) {
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
        
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
      
    } catch (e) {
      _setError('Erro ao criar conta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout do usuário - CORRIGIDO PARA EVITAR TRAVAMENTO
  Future<void> logout({BuildContext? context}) async {
    if (_disposed) return;
    
    try {
      // NÃO usar loading para logout - evita UI travada
      
      // 1. Limpar dados locais IMEDIATAMENTE
      await _clearAuth();
      
      // 2. Notificar servidor em background (sem aguardar)
      _notifyServerLogout();
      
      // 3. Navegação IMEDIATA se contexto fornecido
      if (context != null && context.mounted && !_disposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login, 
              (route) => false,
            );
          }
        });
      }
      
    } catch (e) {
      // Em qualquer erro, garantir limpeza local
      await _clearAuth();
      
      if (context != null && context.mounted && !_disposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login, 
              (route) => false,
            );
          }
        });
      }
    }
  }
  
  /// Notificar servidor sobre logout (não bloqueia UI)
  void _notifyServerLogout() async {
    try {
      await _authService.logout().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    } catch (e) {
      // Falha silenciosa
    }
  }
  
  /// Método SEGURO para logout com confirmação
  Future<void> logoutWithConfirmation(BuildContext context) async {
    if (_disposed || !context.mounted) return;
    
    // Dialog simples SEM await que possa travar
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Executar logout IMEDIATAMENTE
              logout(context: context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
  
  /// Logout FORÇADO para casos de emergência
  void forceLogout(BuildContext context) {
    if (_disposed || !context.mounted) return;
    
    // Limpar estado imediatamente
    _user = null;
    _token = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
    
    // Limpar storage em background
    _storageService.clearAuthData();
    
    // Navegar imediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login, 
          (route) => false,
        );
      }
    });
  }

  /// Atualizar dados do usuário
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Simular chamada para API (implementar quando tiver endpoint)
      await Future.delayed(const Duration(seconds: 1));
      
      // Por enquanto, atualizar localmente
      if (_user != null) {
        _user = _user!.copyWith(name: name, email: email);
        await _updateStoredUser(_user!);
        _safeNotifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
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
      _setLoading(true);
      _clearError();
      
      if (newPassword != confirmPassword) {
        _setError('Nova senha e confirmação não conferem');
        return false;
      }
      
      // Simular chamada para API (implementar quando tiver endpoint)
      await Future.delayed(const Duration(seconds: 1));
      
      // Por enquanto, simular sucesso
      return true;
      
    } catch (e) {
      _setError('Erro ao alterar senha: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh dos dados do usuário
  Future<void> refreshUser() async {
    try {
      if (!isAuthenticated || _disposed) return;
      
      // Simular busca de dados atualizados (implementar quando tiver endpoint)
      await Future.delayed(const Duration(seconds: 1));
      
      _safeNotifyListeners();
    } catch (e) {
      // Ignorar erros no refresh
    }
  }

  void _setState(AuthState newState) {
    if (_state != newState && !_disposed) {
      _state = newState;
      _safeNotifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading && !_disposed) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _setError(String error) {
    if (!_disposed) {
      _errorMessage = error;
      _setState(AuthState.error);
    }
  }

  void _clearError() {
    if (_errorMessage != null && !_disposed) {
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
    } catch (e) {
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
      // Ignorar erros de storage
    }
  }

  Future<void> _clearAuth() async {
    try {
      // Limpar dados do storage
      await _storageService.clearAuthData();
      
      // Limpar variáveis locais
      if (!_disposed) {
        _user = null;
        _token = null;
        _errorMessage = null;
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      if (!_disposed) {
        _setState(AuthState.unauthenticated);
      }
    }
  }

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

  /// Iniciar trial
  Future<bool> startTrial() async {
    try {
      if (_user?.canStartTrial != true) return false;
      
      _user = _user!.startTrial();
      await _updateStoredUser(_user!);
      _safeNotifyListeners();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upgrade para premium
  Future<bool> upgradeToPremium({DateTime? expiresAt}) async {
    try {
      if (_user == null) return false;
      
      _user = _user!.upgradeToPremium(expiresAt: expiresAt);
      await _updateStoredUser(_user!);
      _safeNotifyListeners();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}