

import 'package:flutter/material.dart';
import '../../core/constants/google_config.dart';
import '../../core/services/trial_service.dart';
//import '../auth/google_login_screen.dart';
import '../../models/trial_model.dart';

class TrialOfferScreen extends StatefulWidget {
  const TrialOfferScreen({super.key});

  @override
  State<TrialOfferScreen> createState() => _TrialOfferScreenState();
}

class _TrialOfferScreenState extends State<TrialOfferScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final TrialService _trialService = TrialService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _markTrialAsOffered();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _markTrialAsOffered() async {
    await _trialService.markTrialOffered();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _acceptTrial() async {
  try {
    // Marcar trial como aceito
    await _trialService.markTrialAccepted();
    
    // Navegar para tela de testes (temporário)
    if (mounted) {
      Navigator.pushNamed(context, '/test');
    }
  } catch (e) {
    _showErrorSnackBar('Erro ao aceitar trial: $e');
  }
}

  void _declineTrial() async {
    try {
      // Mostrar confirmação
      final confirmed = await _showDeclineConfirmation();
      if (!confirmed) return;

      // Marcar trial como recusado
      await _trialService.markTrialDeclined();
      
      // Voltar para tela inicial ou fechar app
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Erro: $e');
    }
  }

  Future<bool> _showDeclineConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text(
          'Você não poderá usar o trial gratuito depois. '
          'Deseja realmente continuar sem o teste grátis?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sim, pular trial'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
              Color(0xFF4CAF50),
              Color(0xFF45a049),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header com ícone
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.celebration,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Título principal
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Text(
                    '🎉 Oferta Especial!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtítulo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Text(
                    'Teste GRÁTIS por 7 dias',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    'Experimente todos os recursos premium sem pagar nada!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Lista de benefícios
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'O que você ganha:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        ...GoogleConfig.trialDurationDays == 7 
                          ? [
                              '✅ Treinos ilimitados',
                              '✅ Exercícios personalizados',
                              '✅ Acompanhamento de progresso',
                              '✅ Sincronização na nuvem',
                              '✅ Suporte premium',
                              '✅ Sem anúncios',
                            ].map((benefit) => _buildBenefitItem(benefit))
                          : TrialConfig.defaultConfig.features
                              .map((benefit) => _buildBenefitItem('✅ $benefit')),

                        const Spacer(),

                        // Informações importantes
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sem cobrança durante o teste',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Cancele a qualquer momento',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botões de ação
                Column(
                  children: [
                    // Botão de aceitar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _acceptTrial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4CAF50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch),
                            SizedBox(width: 8),
                            Text(
                              'Começar Teste Grátis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botão de recusar
                    TextButton(
                      onPressed: _declineTrial,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.8),
                      ),
                      child: const Text(
                        'Talvez depois',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    // BOTÃO DE DEBUG (remover em produção)
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/test');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.5),
                      ),
                      child: const Text(
                        '🧪 Debug/Testes',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            benefit,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}