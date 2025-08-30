import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider_google.dart';

/// Tela de Login com Google Sign In
class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonAnimation;
  
  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
    
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonController.forward();
    });
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
    
    HapticFeedback.lightImpact();
    
    try {
      final result = await authProvider.signInWithGoogle();
      
      if (!result['success'] && mounted) {
        _showErrorSnackBar(result['message'] ?? 'Erro no login');
        HapticFeedback.heavyImpact();
      }
      
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro interno. Tente novamente.');
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
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
                      'Pagamentos',
                      'Os pagamentos são processados exclusivamente pela Google Play Store. Você pode cancelar sua assinatura a qualquer momento.',
                    ),
                    _buildPolicySection(
                      'Contato',
                      'Para dúvidas ou solicitações sobre seus dados, entre em contato através do email: contato@treinoapp.com',
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6BA6CD),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D3748),
              Color(0xFF4A5568),
              Color(0xFF6BA6CD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6BA6CD), Color(0xFF5B9BD5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6BA6CD).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
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
              
              // BOTÕES
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
                        Consumer<AuthProviderGoogle>(
                          builder: (context, authProvider, child) {
                            return ScaleTransition(
                              scale: _buttonAnimation,
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: authProvider.isLoading ? null : _signInWithGoogle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF374151),
                                    elevation: 8,
                                    shadowColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  icon: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SpinKitFadingCircle(
                                            color: Color(0xFF6BA6CD),
                                            size: 20,
                                          ),
                                        )
                                      : const FaIcon(
                                          FontAwesomeIcons.google,
                                          size: 20,
                                          color: Color(0xFFDB4437),
                                        ),
                                  label: Text(
                                    authProvider.isLoading 
                                        ? 'Entrando...' 
                                        : 'Continuar com Google',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // TRIAL INFO
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF48BB78), Color(0xFF38A169)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF48BB78).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '7 Dias Grátis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Teste premium sem compromisso',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
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
              
              // FOOTER
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