import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/google_config.dart';
import '../../models/user_model.dart';
import '../../models/api_response_model.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static GoogleSignIn? _googleSignIn;

  // Inicializar Google Sign In
  static GoogleSignIn get _instance {
    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn(
        clientId: GoogleConfig.webClientId,
        scopes: [
          'email',
          'profile',
        ],
      );
      print('🔧 Google Sign In inicializado');
    }
    return _googleSignIn!;
  }

  // 🔑 LOGIN COM GOOGLE
  static Future<ApiResponse<User>> signInWithGoogle() async {
    try {
      print('🔑 Iniciando login com Google...');

      // Fazer logout primeiro para sempre mostrar seleção de conta
      await _instance.signOut();

      // Fazer login
      final GoogleSignInAccount? googleUser = await _instance.signIn();
      
      if (googleUser == null) {
        print('❌ Usuário cancelou o login');
        return ApiResponse<User>.error(
          message: 'Login cancelado pelo usuário',
        );
      }

      print('✅ Usuário Google selecionado: ${googleUser.email}');

      // Obter token de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        print('❌ Não foi possível obter token de acesso');
        return ApiResponse<User>.error(
          message: 'Erro ao obter credenciais do Google',
        );
      }

      print('✅ Token Google obtido');

      // Enviar para nossa API Laravel
      final response = await _sendGoogleTokenToAPI(
        googleUser: googleUser,
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken,
      );

      return response;

    } catch (e) {
      print('❌ Erro no login com Google: $e');
      return ApiResponse<User>.error(
        message: 'Erro ao fazer login com Google: ${e.toString()}',
      );
    }
  }

  // 📡 ENVIAR TOKEN PARA API LARAVEL
  static Future<ApiResponse<User>> _sendGoogleTokenToAPI({
    required GoogleSignInAccount googleUser,
    required String accessToken,
    String? idToken,
  }) async {
    try {
      print('📡 Enviando dados do Google para API Laravel...');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'access_token': accessToken,
          'id_token': idToken,
          'google_id': googleUser.id,
          'name': googleUser.displayName ?? '',
          'email': googleUser.email,
          'avatar_url': googleUser.photoUrl,
        }),
      );

      print('📡 Status resposta Laravel: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sucesso - salvar dados como no login normal
        final user = User.fromJson(data['data']['user']);
        final token = data['data']['token'];
        
        // Salvar token e usuário usando AuthService
        await AuthService.saveTokenAndUser(token, user);
        
        print('✅ Login com Google realizado com sucesso!');
        return ApiResponse<User>.success(
          data: user,
          message: data['message'] ?? 'Login com Google realizado com sucesso!',
        );
      } else {
        print('❌ Erro na API Laravel: ${data['message']}');
        return ApiResponse<User>.error(
          message: data['message'] ?? 'Erro ao processar login com Google',
          errors: data['errors'],
        );
      }

    } catch (e) {
      print('❌ Erro ao enviar para API: $e');
      return ApiResponse<User>.error(
        message: 'Erro de conexão com o servidor',
      );
    }
  }

  // 🚪 LOGOUT DO GOOGLE
  static Future<void> signOut() async {
    try {
      print('🚪 Fazendo logout do Google...');
      await _instance.signOut();
      print('✅ Logout do Google realizado');
    } catch (e) {
      print('❌ Erro no logout do Google: $e');
    }
  }

  // 🔄 VERIFICAR SE ESTÁ LOGADO NO GOOGLE
  static Future<bool> isSignedIn() async {
    try {
      final isSignedIn = await _instance.isSignedIn();
      print('🔍 Google Sign In status: $isSignedIn');
      return isSignedIn;
    } catch (e) {
      print('❌ Erro ao verificar status do Google: $e');
      return false;
    }
  }

  // 👤 OBTER USUÁRIO ATUAL DO GOOGLE
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      final user = await _instance.signInSilently();
      if (user != null) {
        print('👤 Usuário Google atual: ${user.email}');
      } else {
        print('👤 Nenhum usuário Google logado');
      }
      return user;
    } catch (e) {
      print('❌ Erro ao obter usuário Google: $e');
      return null;
    }
  }

  // 🔄 LOGIN SILENCIOSO (sem popup)
  static Future<ApiResponse<User>?> signInSilently() async {
    try {
      print('🔄 Tentando login silencioso com Google...');
      
      final GoogleSignInAccount? googleUser = await _instance.signInSilently();
      
      if (googleUser == null) {
        print('🔍 Nenhum usuário Google para login silencioso');
        return null;
      }

      print('✅ Login silencioso encontrou usuário: ${googleUser.email}');

      // Obter token e enviar para API
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken != null) {
        return await _sendGoogleTokenToAPI(
          googleUser: googleUser,
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken,
        );
      } else {
        print('❌ Token não disponível para login silencioso');
        return null;
      }

    } catch (e) {
      print('❌ Erro no login silencioso: $e');
      return null;
    }
  }

  // 🛠️ DESCONECTAR COMPLETAMENTE (revogar acesso)
  static Future<void> disconnect() async {
    try {
      print('🛠️ Desconectando conta Google...');
      await _instance.disconnect();
      print('✅ Conta Google desconectada');
    } catch (e) {
      print('❌ Erro ao desconectar Google: $e');
    }
  }

  // 🔧 VERIFICAR CONFIGURAÇÃO
  static bool isConfigured() {
    try {
      return GoogleConfig.webClientId.isNotEmpty && 
             GoogleConfig.webClientId != 'YOUR_WEB_CLIENT_ID';
    } catch (e) {
      print('❌ Erro ao verificar configuração Google: $e');
      return false;
    }
  }

  // 📱 INFORMAÇÕES DE DEBUG
  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final isSignedIn = await GoogleAuthService.isSignedIn();
      final currentUser = await getCurrentUser();
      
      return {
        'is_configured': isConfigured(),
        'is_signed_in': isSignedIn,
        'current_user_email': currentUser?.email,
        'current_user_name': currentUser?.displayName,
        'web_client_id': GoogleConfig.webClientId,
        'client_id_configured': GoogleConfig.webClientId != 'YOUR_WEB_CLIENT_ID',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'is_configured': false,
        'is_signed_in': false,
      };
    }
  }
}