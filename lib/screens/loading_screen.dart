import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/services/google_auth_service.dart';

/// Tela de loading intermediária - feedback para o usuário
class LoadingScreen extends StatefulWidget {
  final String message;
  final bool isNewUser;
  
  const LoadingScreen({
    super.key,
    required this.message,
    this.isNewUser = false,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> 
    with TickerProviderStateMixin {
  
  // ===== CONTROLLERS =====
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  // ===== ESTADO =====
  String _currentMessage = '';
  int _currentStep = 0;
  
  final List<String> _loadingSteps = [
    'Configurando sua conta...',
    'Carregando treinos...',
    'Preparando interface...',
    'Quase pronto...',
  ];

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    _setupAnimations();
    _startLoadingSequence();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Configurar animações
  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animações
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  /// Iniciar sequência de loading
  void _startLoadingSequence() async {
    // Se for usuário novo, mostrar steps especiais
    if (widget.isNewUser) {
      await _runNewUserSequence();
    } else {
      await _runExistingUserSequence();
    }
  }

  /// Sequência para usuário novo
  Future<void> _runNewUserSequence() async {
    final newUserSteps = [
      'Criando sua conta...',
      'Configurando trial gratuito...',
      'Preparando seus treinos...',
      'Bem-vindo ao Treino App!',
    ];
    
    for (int i = 0; i < newUserSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentMessage = newUserSteps[i];
          _currentStep = i;
        });
      }
    }
  }

  /// Sequência para usuário existente
  Future<void> _runExistingUserSequence() async {
    for (int i = 0; i < _loadingSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _currentMessage = _loadingSteps[i];
          _currentStep = i;
        });
      }
    }
  }

  /// Obter ícone baseado no step atual
  IconData _getCurrentIcon() {
    if (widget.isNewUser) {
      switch (_currentStep) {
        case 0: return Icons.person_add;
        case 1: return Icons.star;
        case 2: return Icons.fitness_center;
        case 3: return Icons.check_circle;
        default: return Icons.fitness_center;
      }
    } else {
      switch (_currentStep) {
        case 0: return Icons.settings;
        case 1: return Icons.fitness_center;
        case 2: return Icons.dashboard;
        case 3: return Icons.check_circle;
        default: return Icons.fitness_center;
      }
    }
  }

  /// Obter cor baseada no step atual
  Color _getCurrentColor() {
    switch (_currentStep) {
      case 0: return const Color(0xFF667eea);
      case 1: return const Color(0xFF764ba2);
      case 2: return const Color(0xFF667eea);
      case 3: return Colors.green;
      default: return const Color(0xFF667eea);
    }
  }

  /// Widget de informações do usuário
  Widget _buildUserInfo() {
    final user = GoogleAuthService().currentUser;
    if (user == null) return const SizedBox.shrink();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Avatar (placeholder)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nome
          Text(
            'Olá, ${user.name.split(' ').first}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status trial/premium
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: user.hasAccess 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.hasAccess 
                    ? Colors.green.withOpacity(0.4)
                    : Colors.orange.withOpacity(0.4),
              ),
            ),
            child: Text(
              user.isPremium 
                  ? 'Premium' 
                  : user.isInTrial 
                      ? 'Trial ${user.trialDaysLeft} dias'
                      : 'Trial expirado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: user.hasAccess ? Colors.green : Colors.orange,
              ),
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Expanded(
                flex: 2,
                child: Center(
                  child: _buildUserInfo(),
                ),
              ),
              
              // ===== LOADING AREA =====
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ÍCONE ANIMADO
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getCurrentColor(),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: _getCurrentColor().withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCurrentIcon(),
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // SPINNER
                      const SpinKitPulse(
                        color: Colors.white,
                        size: 50.0,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // MENSAGEM
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _currentMessage,
                          key: ValueKey(_currentMessage),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // PROGRESS INDICATOR
                      Container(
                        width: 200,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (_currentStep + 1) / 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // ===== FOOTER =====
              Expanded(
                flex: 1,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.isNewUser) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 32),
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
                                color: Colors.yellow[400],
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Parabéns!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Você ganhou 7 dias premium grátis',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      Text(
                        'Treino App',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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