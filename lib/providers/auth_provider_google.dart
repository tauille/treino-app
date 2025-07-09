import 'package:flutter/foundation.dart';
import '../core/services/google_auth_service.dart';
import '../models/user_model.dart';

/// Provider para gerenciar estado de autenticação Google
class AuthProviderGoogle extends ChangeNotifier {
  // ===== ESTADO =====
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // ===== GETTERS =====
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Verificar status de autenticação inicial
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final authService = GoogleAuthService();
      
      if (authService.isLoggedIn) {
        // Verificar se token ainda é válido
        final isValid = await authService.verifyToken();
        
        if (isValid) {
          // Token válido - atualizar dados do usuário
          final result = await authService.refreshUserData();
          
          if (result['success']) {
            _updateUser(authService.currentUser);
          } else {
            await signOut();
          }
        } else {
          // Token inválido - fazer logout
          await signOut();
        }
      } else {
        // Não logado
        _clearUser();
      }
    } catch (e) {
      _setError('Erro ao verificar autenticação: $e');
      if (kDebugMode) print('❌ Erro checkAuthStatus: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Fazer login com Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await GoogleAuthService().signInWithGoogle();
      
      if (result['success']) {
        _updateUser(GoogleAuthService().currentUser);
        
        return {
          'success': true,
          'message': result['message'],
          'isNewUser': result['isNewUser'] ?? false,
        };
      } else {
        _setError(result['message']);
        return result;
      }
    } catch (e) {
      final error = 'Erro no login: $e';
      _setError(error);
      if (kDebugMode) print('❌ Erro signInWithGoogle: $e');
      
      return {
        'success': false,
        'message': 'Erro interno. Tente novamente.',
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }
  
  /// Fazer logout
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await GoogleAuthService().signOut();
      _clearUser();
      
      if (kDebugMode) print('✅ Logout realizado com sucesso');
    } catch (e) {
      _setError('Erro no logout: $e');
      if (kDebugMode) print('❌ Erro signOut: $e');
      
      // Mesmo com erro, limpar dados locais
      _clearUser();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Atualizar dados do usuário
  Future<Map<String, dynamic>> refreshUserData() async {
    try {
      final result = await GoogleAuthService().refreshUserData();
      
      if (result['success']) {
        _updateUser(result['user']);
        return {'success': true, 'user': _user};
      } else {
        _setError('Erro ao atualizar dados');
        return result;
      }
    } catch (e) {
      _setError('Erro ao atualizar usuário: $e');
      if (kDebugMode) print('❌ Erro refreshUserData: $e');
      
      return {
        'success': false,
        'message': 'Erro de conexão',
        'error': e.toString(),
      };
    }
  }
  
  /// Verificar se usuário tem acesso premium
  bool get hasAccess => _user?.hasAccess ?? false;
  
  /// Verificar se está no trial
  bool get isInTrial => _user?.isInTrial ?? false;
  
  /// Verificar se é premium
  bool get isPremium => _user?.isPremium ?? false;
  
  /// Dias restantes do trial
  int get trialDaysLeft => _user?.trialDaysLeft ?? 0;
  
  /// Status do usuário (Premium, Trial X dias, Trial expirado)
  String get userStatus {
    if (_user == null) return 'Não logado';
    
    if (_user!.isPremium) {
      return 'Premium Ativo';
    } else if (_user!.isInTrial) {
      return 'Trial ${_user!.trialDaysLeft} dias';
    } else {
      return 'Trial Expirado';
    }
  }
  
  /// Cor do status
  String get statusColor {
    if (_user == null) return 'grey';
    
    if (_user!.isPremium) {
      return 'green';
    } else if (_user!.isInTrial) {
      return 'blue';
    } else {
      return 'red';
    }
  }
  
  // ===== MÉTODOS PRIVADOS =====
  
  /// Atualizar dados do usuário
  void _updateUser(UserModel? user) {
    _user = user;
    _isAuthenticated = user != null;
    _clearError();
    notifyListeners();
    
    if (kDebugMode && user != null) {
      print('✅ Usuário atualizado: ${user.name}');
      print('📊 Status: ${userStatus}');
      print('⭐ Acesso: ${hasAccess ? 'SIM' : 'NÃO'}');
    }
  }
  
  /// Limpar dados do usuário
  void _clearUser() {
    _user = null;
    _isAuthenticated = false;
    _clearError();
    notifyListeners();
    
    if (kDebugMode) print('🗑️ Dados do usuário limpos');
  }
  
  /// Definir estado de loading
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// Definir erro
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  /// Limpar erro
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  /// Limpar estado completamente (para logout)
  void clearState() {
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    
    if (kDebugMode) print('🧹 Estado completamente limpo');
  }
  
  // ===== MÉTODOS DE UTILIDADE =====
  
  /// Verificar se precisa renovar trial/premium
  bool get needsUpgrade => !hasAccess;
  
  /// Mensagem de call-to-action
  String get ctaMessage {
    if (_user == null) return 'Faça login para começar';
    
    if (_user!.isPremium) {
      return 'Aproveite seus treinos premium!';
    } else if (_user!.isInTrial) {
      return '${_user!.trialDaysLeft} dias restantes do trial';
    } else {
      return 'Assine para continuar treinando';
    }
  }
  
  @override
  void dispose() {
    if (kDebugMode) print('🗑️ AuthProviderGoogle disposed');
    super.dispose();
  }
}