import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/services/google_auth_service.dart';
import '../core/theme/sport_theme.dart'; // ✅ Importar tema padrão
import 'home/home_screen.dart';  // ✅ CORRIGIDO: caminho correto
import 'loading_screen.dart';

/// Tela de Login com Google Sign In - CORES PADRONIZADAS
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin {
  
  // ===== CONTROLLERS =====
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonAnimation;
  
  // ===== ESTADO =====
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar status bar para tema claro
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // ✅ Ícones escuros para tema claro
      ),
    );
    
    _setupAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  /// Configurar animações
  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animações
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonController.forward();
    });
  }

  /// Fazer login com Google
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Feedback háptico
      HapticFeedback.lightImpact();
      
      // Fazer login
      final result = await GoogleAuthService().signInWithGoogle();
      
      if (result['success']) {
        // Sucesso - navegar para home
        if (mounted) {
          // Mostrar loading temporário
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, _) => LoadingScreen(
                message: result['message'] ?? 'Login realizado com sucesso!',
                isNewUser: result['isNewUser'] ?? false,
              ),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
          
          // Após 2 segundos, ir para home
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, _) => const HomeScreen(),
                  transitionDuration: const Duration(milliseconds: 600),
                  transitionsBuilder: (context, animation, _, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            }
          });
        }
      } else {
        // Erro no login
        _showError(result['message'] ?? 'Erro desconhecido');
      }
      
    } catch (e) {
      _showError('Erro interno. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Mostrar erro
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    // Feedback háptico de erro
    HapticFeedback.heavyImpact();
    
    // Limpar erro após 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  /// Mostrar política de privacidade
  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: SportColors.backgroundCard, // ✅ Fundo branco padrão
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SportColors.grey300, // ✅ Cinza padrão
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SportColors.textPrimary, // ✅ Texto principal padrão
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: SportColors.textSecondary, // ✅ Texto secundário padrão
                    ),
                  ),
                ],
              ),
            ),
            
            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySection(
                      'Dados Coletados',
                      'Coletamos apenas informações básicas do seu perfil Google: nome, email e foto. Estes dados são utilizados exclusivamente para personalizar sua experiência no app.',
                    ),
                    _buildPolicySection(
                      'Trial Gratuito',
                      'Oferecemos 7 dias de trial gratuito. Após este período, é necessário assinar o plano premium para continuar usando o app.',
                    ),
                    _buildPolicySection(
                      'Segurança',
                      'Seus dados são protegidos com criptografia e armazenados de forma segura. Não compartilhamos suas informações com terceiros.',
                    ),
                    _buildPolicySection(
                      'Cancelamento',
                      'Você pode cancelar sua assinatura a qualquer momento através da Google Play Store.',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SportColors.primary, // ✅ Azul/turquesa padrão
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: SportColors.textSecondary, // ✅ Texto secundário padrão
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: SportColors.primaryGradient, // ✅ Gradiente azul/turquesa padrão
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          size: 50,
                          color: SportColors.primary, // ✅ Azul/turquesa padrão
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // TÍTULO
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // SUBTÍTULO
                      Text(
                        'Entre com sua conta Google para\ncomeçar seus treinos personalizados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // ===== BOTÕES =====
              Expanded(
                flex: 1,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // BOTÃO GOOGLE SIGN IN
                        ScaleTransition(
                          scale: _buttonAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: SportColors.textSecondary, // ✅ Texto secundário padrão
                                elevation: 3,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SpinKitFadingCircle(
                                        color: SportColors.primary, // ✅ Azul/turquesa padrão
                                        size: 20,
                                      ),
                                    )
                                  : const FaIcon(
                                      FontAwesomeIcons.google,
                                      size: 20,
                                      color: Color(0xFFDB4437),
                                    ),
                              label: Text(
                                _isLoading 
                                    ? 'Entrando...' 
                                    : 'Continuar com Google',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // MENSAGEM DE ERRO
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: SportColors.error.withOpacity(0.1), // ✅ Vermelho padrão
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: SportColors.error.withOpacity(0.3), // ✅ Vermelho padrão
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: SportColors.error, // ✅ Vermelho padrão
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: SportColors.error, // ✅ Vermelho padrão
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // TRIAL INFO
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.star,
                                color: SportColors.warning, // ✅ Laranja padrão
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '7 Dias Grátis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Teste premium sem compromisso',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // ===== FOOTER =====
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton(
                  onPressed: _showPrivacyPolicy,
                  child: Text(
                    'Política de Privacidade',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}