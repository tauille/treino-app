import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    
    // Inicializar o AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🔍 AuthWrapper State: ${authProvider.state}');
        print('🔍 Authenticated: ${authProvider.isAuthenticated}');
        
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return _buildLoadingScreen();
            
          case AuthState.authenticated:
            return const HomeScreen();
            
          case AuthState.unauthenticated:
          case AuthState.error:
            // Verificar se é primeira vez abrindo o app
            return _buildUnauthenticatedFlow();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nome do app
            Text(
              'Treino App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Carregando...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedFlow() {
    return FutureBuilder<bool>(
      future: _isFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        
        final isFirstTime = snapshot.data ?? true;
        
        if (isFirstTime) {
          // Primeira vez - mostrar welcome/onboarding
          return const WelcomeScreen();
        } else {
          // Não é primeira vez - ir direto para login
          return const LoginScreen();
        }
      },
    );
  }

  Future<bool> _isFirstTime() async {
    // Verificar se é primeira vez usando o mesmo sistema do trial
    final trialService = Provider.of<AuthProvider>(context, listen: false);
    
    // Se tem dados salvos de usuário, não é primeira vez
    final user = await Provider.of<AuthProvider>(context, listen: false);
    
    // Por simplicidade, vamos usar uma lógica básica:
    // Se nunca fez login antes, é primeira vez
    return true; // Por enquanto sempre mostra welcome
  }
}

// Widget para facilitar navegação programática
class AuthNavigator {
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  static void navigateToWelcome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  static Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      navigateToLogin(context);
    }
  }
}