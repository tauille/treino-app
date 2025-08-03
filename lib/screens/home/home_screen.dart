import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_google.dart';
import '../../providers/treino_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/treino_model.dart';
import '../treino/meus_treinos_screen.dart';
import '../treino/criar_treino_screen.dart';

/// 🏋️ Home Screen Moderna - OTIMIZADA PARA TELAS MENORES
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  List<TreinoModel> _treinosRecentes = [];
  bool _isLoadingTreinos = false;

  @override
  void initState() {
    super.initState();
    
    // Configurar status bar moderno
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    _setupAnimations();
    _carregarTreinosRecentes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// 🎨 Configurar animações simplificadas
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800), // 🔧 REDUZIDO: 1200→800
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500), // 🔧 REDUZIDO: 2000→1500
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut, // 🔧 SIMPLIFICADO: easeOutCubic→easeOut
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02, // 🔧 REDUZIDO: 1.05→1.02 (pulso mais sutil)
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  /// Carregar treinos recentes
  Future<void> _carregarTreinosRecentes() async {
    setState(() => _isLoadingTreinos = true);
    
    final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
    final resultado = await treinoProvider.listarTreinos();
    
    if (resultado.success && resultado.data != null) {
      setState(() {
        _treinosRecentes = (resultado.data as List<TreinoModel>)
            .where((treino) => treino.exercicios.isNotEmpty)
            .take(4)
            .toList();
      });
    }
    
    setState(() => _isLoadingTreinos = false);
  }

  /// Fazer logout
  Future<void> _signOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 🔧 REDUZIDO: 20→16
        ),
        title: const Text(
          'Confirmar Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // 🔧 ADICIONADO: fonte específica
          ),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(fontSize: 14), // 🔧 ADICIONADO: fonte menor
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14, // 🔧 ADICIONADO
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontSize: 14), // 🔧 ADICIONADO
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
      await authProvider.signOut();
    }
  }

  /// 🏋️ Navegar para Meus Treinos
  void _navigateToMeusTreinos() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MeusTreinosScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOut; // 🔧 SIMPLIFICADO: easeInOutCubic→easeOut
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), // 🔧 REDUZIDO: 400→300
      ),
    );
  }

  /// 🆕 Navegar para Criar Treino
  void _navigateToCriarTreino() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CriarTreinoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut; // 🔧 SIMPLIFICADO
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), // 🔧 REDUZIDO: 400→300
      ),
    );
  }

  /// 🎯 Iniciar treino específico
  void _iniciarTreino(TreinoModel treino) {
    HapticFeedback.mediumImpact();
    
    // Feedback visual moderno
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 20, // 🔧 REDUZIDO: 24→20
              height: 20, // 🔧 REDUZIDO: 24→20
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Color(0xFF4ECDC4), size: 14), // 🔧 REDUZIDO: 16→14
            ),
            const SizedBox(width: 10), // 🔧 REDUZIDO: 12→10
            Expanded(
              child: Text(
                'Iniciando "${treino.nomeTreino}"...',
                style: const TextStyle(fontSize: 14), // 🔧 ADICIONADO
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 🔧 REDUZIDO: 16→12
        margin: const EdgeInsets.all(12), // 🔧 REDUZIDO: 16→12
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Navegar para preparação
    Navigator.pushNamed(
      context,
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }

  /// 🆕 Mostrar lista de treinos para escolher
  void _mostrarTreinosDisponiveis() async {
    HapticFeedback.lightImpact();
    
    final treino = await showModalBottomSheet<TreinoModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTreinoBottomSheet(),
    );
    
    if (treino != null) {
      _iniciarTreino(treino);
    }
  }

  /// 🎨 Widget do status do usuário - COMPACTO
  Widget _buildUserStatus() {
    return Consumer<AuthProviderGoogle>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 20), // 🔧 REDUZIDO: 20,8,20,24→16,6,16,20
          padding: const EdgeInsets.all(18), // 🔧 REDUZIDO: 24→18
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: user.hasAccess
                  ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                  : [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // 🔧 REDUZIDO: 24→20
            boxShadow: [
              BoxShadow(
                color: (user.hasAccess ? const Color(0xFF667EEA) : const Color(0xFFFF6B6B))
                    .withOpacity(0.25), // 🔧 REDUZIDO: 0.3→0.25
                blurRadius: 15, // 🔧 REDUZIDO: 20→15
                offset: const Offset(0, 6), // 🔧 REDUZIDO: 8→6
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar compacto
                  Container(
                    width: 56, // 🔧 REDUZIDO: 68→56
                    height: 56, // 🔧 REDUZIDO: 68→56
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16), // 🔧 REDUZIDO: 20→16
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // 🔧 REDUZIDO: 24→20
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16), // 🔧 REDUZIDO: 20→16
                  
                  // Info do usuário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${user.firstName}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18, // 🔧 REDUZIDO: 24→18 (-25%)
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4), // 🔧 REDUZIDO: 6→4
                        Text(
                          user.motivationalMessage,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12, // 🔧 REDUZIDO: 15→12 (-20%)
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16), // 🔧 REDUZIDO: 20→16
              
              // Status bar compacta
              Container(
                padding: const EdgeInsets.all(12), // 🔧 REDUZIDO: 16→12
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12), // 🔧 REDUZIDO: 16→12
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28, // 🔧 REDUZIDO: 32→28
                      height: 28, // 🔧 REDUZIDO: 32→28
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6), // 🔧 REDUZIDO: 8→6
                      ),
                      child: Icon(
                        user.isPremium 
                            ? Icons.diamond 
                            : user.isInTrial 
                                ? Icons.schedule 
                                : Icons.lock_outline,
                        color: Colors.white,
                        size: 16, // 🔧 REDUZIDO: 18→16
                      ),
                    ),
                    const SizedBox(width: 10), // 🔧 REDUZIDO: 12→10
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13, // 🔧 REDUZIDO: 15→13
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (user.isInTrial) ...[
                            const SizedBox(height: 1), // 🔧 REDUZIDO: 2→1
                            Text(
                              'Expira em ${user.trialExpiresAt?.day}/${user.trialExpiresAt?.month}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11, // 🔧 REDUZIDO: 13→11
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!user.hasAccess)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tela de assinatura será implementada',
                                    style: TextStyle(fontSize: 14), // 🔧 ADICIONADO
                                  ),
                                  backgroundColor: Color(0xFF4ECDC4),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 🔧 REDUZIDO: 16,8→12,6
                              child: Text(
                                'Assinar',
                                style: TextStyle(
                                  color: user.hasAccess ? const Color(0xFF667EEA) : const Color(0xFFFF6B6B),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12, // 🔧 REDUZIDO: 14→12
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🚀 Seção de ação principal - COMPACTA
  Widget _buildMainActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
          child: Text(
            'Vamos Treinar?',
            style: TextStyle(
              fontSize: 21, // 🔧 REDUZIDO: 28→21 (-25%)
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        
        const SizedBox(height: 16), // 🔧 REDUZIDO: 20→16
        
        // Botões principais compactos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
          child: Row(
            children: [
              // INICIAR TREINO
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _treinosRecentes.isNotEmpty ? _pulseAnimation.value : 1.0,
                      child: Container(
                        height: 100, // 🔧 REDUZIDO: 140→100 (-29%)
                        decoration: BoxDecoration(
                          gradient: _treinosRecentes.isNotEmpty
                              ? const LinearGradient(
                                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                                ),
                          borderRadius: BorderRadius.circular(16), // 🔧 REDUZIDO: 20→16
                          boxShadow: _treinosRecentes.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4).withOpacity(0.3), // 🔧 REDUZIDO: 0.4→0.3
                                    blurRadius: 15, // 🔧 REDUZIDO: 20→15
                                    offset: const Offset(0, 6), // 🔧 REDUZIDO: 8→6
                                  )
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _treinosRecentes.isNotEmpty 
                                ? _mostrarTreinosDisponiveis
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16), // 🔧 REDUZIDO: 20→16
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36, // 🔧 REDUZIDO: 48→36
                                    height: 36, // 🔧 REDUZIDO: 48→36
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
                                    ),
                                    child: Icon(
                                      _treinosRecentes.isNotEmpty
                                          ? Icons.play_arrow_rounded
                                          : Icons.fitness_center,
                                      color: Colors.white,
                                      size: 20, // 🔧 REDUZIDO: 24→20
                                    ),
                                  ),
                                  
                                  const Spacer(),
                                  
                                  Text(
                                    _treinosRecentes.isNotEmpty
                                        ? 'Iniciar Treino'
                                        : 'Nenhum Treino',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14, // 🔧 REDUZIDO: 18→14 (-22%)
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 2), // 🔧 REDUZIDO: 4→2
                                  
                                  Text(
                                    _treinosRecentes.isNotEmpty
                                        ? '${_treinosRecentes.length} disponíveis'
                                        : 'Crie seu primeiro',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11, // 🔧 REDUZIDO: 14→11 (-21%)
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 12), // 🔧 REDUZIDO: 16→12
              
              // CRIAR TREINO
              Expanded(
                flex: 1,
                child: Container(
                  height: 100, // 🔧 REDUZIDO: 140→100 (-29%)
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16), // 🔧 REDUZIDO: 20→16
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3), // 🔧 REDUZIDO: 0.4→0.3
                        blurRadius: 15, // 🔧 REDUZIDO: 20→15
                        offset: const Offset(0, 6), // 🔧 REDUZIDO: 8→6
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToCriarTreino,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16), // 🔧 REDUZIDO: 20→16
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36, // 🔧 REDUZIDO: 48→36
                              height: 36, // 🔧 REDUZIDO: 48→36
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20, // 🔧 REDUZIDO: 24→20
                              ),
                            ),
                            
                            const Spacer(),
                            
                            const Text(
                              'Criar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14, // 🔧 REDUZIDO: 18→14 (-22%)
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            
                            const SizedBox(height: 2), // 🔧 REDUZIDO: 4→2
                            
                            Text(
                              'Novo treino',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11, // 🔧 REDUZIDO: 14→11 (-21%)
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🏃 Lista de treinos recentes - COMPACTA
  Widget _buildTreinosRecentes() {
    if (_treinosRecentes.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Treinos Recentes',
                style: TextStyle(
                  fontSize: 17, // 🔧 REDUZIDO: 22→17 (-23%)
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: _navigateToMeusTreinos,
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // 🔧 REDUZIDO: 16→13 (-19%)
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12), // 🔧 REDUZIDO: 16→12
        
        SizedBox(
          height: 120, // 🔧 REDUZIDO: 160→120 (-25%)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
            itemCount: _treinosRecentes.length,
            itemBuilder: (context, index) {
              final treino = _treinosRecentes[index];
              return _buildTreinoCardModerno(treino, index);
            },
          ),
        ),
      ],
    );
  }

  /// 🎨 Card de treino compacto
  Widget _buildTreinoCardModerno(TreinoModel treino, int index) {
    final colors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
      [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      [const Color(0xFF9D50BB), const Color(0xFF6E48AA)],
    ];
    
    final cardColors = colors[index % colors.length];
    
    return Container(
      width: 160, // 🔧 REDUZIDO: 220→160 (-27%)
      margin: const EdgeInsets.only(right: 12), // 🔧 REDUZIDO: 16→12
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16), // 🔧 REDUZIDO: 20→16
        boxShadow: [
          BoxShadow(
            color: cardColors[0].withOpacity(0.25), // 🔧 REDUZIDO: 0.3→0.25
            blurRadius: 12, // 🔧 REDUZIDO: 15→12
            offset: const Offset(0, 6), // 🔧 REDUZIDO: 8→6
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _iniciarTreino(treino),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14), // 🔧 REDUZIDO: 20→14
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 8, // 🔧 REDUZIDO: 12→8
                      height: 8, // 🔧 REDUZIDO: 12→8
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6), // 🔧 REDUZIDO: 8→6
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6), // 🔧 REDUZIDO: 8→6
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 12, // 🔧 REDUZIDO: 16→12
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8), // 🔧 REDUZIDO: 20→8
                
                Text(
                  treino.nomeTreino,
                  style: const TextStyle(
                    fontSize: 13, // 🔧 REDUZIDO: 18→13 (-28%)
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4), // 🔧 REDUZIDO: 8→4
                
                Text(
                  treino.tipoTreino,
                  style: TextStyle(
                    fontSize: 10, // 🔧 REDUZIDO: 14→10 (-29%)
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const Spacer(),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${treino.exercicios.length}',
                          style: const TextStyle(
                            fontSize: 18, // 🔧 REDUZIDO: 24→18 (-25%)
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'exercícios',
                          style: TextStyle(
                            fontSize: 9, // 🔧 REDUZIDO: 12→9 (-25%)
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      treino.dificuldade?.toUpperCase() ?? 'TREINO',
                      style: TextStyle(
                        fontSize: 8, // 🔧 REDUZIDO: 10→8 (-20%)
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5, // 🔧 REDUZIDO: 1→0.5
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔧 Funcionalidades principais - COMPACTAS
  Widget _buildFuncionalidades() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
          child: Text(
            'Explorar',
            style: TextStyle(
              fontSize: 17, // 🔧 REDUZIDO: 22→17 (-23%)
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        
        const SizedBox(height: 12), // 🔧 REDUZIDO: 16→12
        
        _buildFeatureCard(
          title: 'Meus Treinos',
          description: 'Gerencie todos os seus treinos',
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFF4ECDC4),
          onTap: _navigateToMeusTreinos,
        ),
        
        _buildFeatureCard(
          title: 'Histórico',
          description: 'Acompanhe seu progresso',
          icon: Icons.analytics_rounded,
          color: const Color(0xFF667EEA),
          isEnabled: false,
          onTap: () => _showComingSoon('Histórico'),
        ),
      ],
    );
  }

  /// 🃏 Card de funcionalidade compacto
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // 🔧 REDUZIDO: 20,8→16,6
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // 🔧 REDUZIDO: 16→12
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // 🔧 REDUZIDO: 0.05→0.04
            blurRadius: 8, // 🔧 REDUZIDO: 10→8
            offset: const Offset(0, 3), // 🔧 REDUZIDO: 4→3
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16), // 🔧 REDUZIDO: 20→16
            child: Row(
              children: [
                Container(
                  width: 44, // 🔧 REDUZIDO: 56→44 (-21%)
                  height: 44, // 🔧 REDUZIDO: 56→44 (-21%)
                  decoration: BoxDecoration(
                    color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12), // 🔧 REDUZIDO: 16→12
                  ),
                  child: Icon(
                    icon,
                    color: isEnabled ? color : Colors.grey,
                    size: 22, // 🔧 REDUZIDO: 28→22 (-21%)
                  ),
                ),
                
                const SizedBox(width: 12), // 🔧 REDUZIDO: 16→12
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14, // 🔧 REDUZIDO: 18→14 (-22%)
                          fontWeight: FontWeight.w700,
                          color: isEnabled ? const Color(0xFF2D3748) : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2), // 🔧 REDUZIDO: 4→2
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11, // 🔧 REDUZIDO: 14→11 (-21%)
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // 🔧 REDUZIDO: 12,6→10,4
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? const Color(0xFF4ECDC4).withOpacity(0.1)
                        : Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8), // 🔧 REDUZIDO: 12→8
                  ),
                  child: Text(
                    isEnabled ? 'Ativo' : 'Em breve',
                    style: TextStyle(
                      fontSize: 10, // 🔧 REDUZIDO: 12→10 (-17%)
                      fontWeight: FontWeight.w600,
                      color: isEnabled 
                          ? const Color(0xFF4ECDC4)
                          : Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet compacto
  Widget _buildTreinoBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // 🔧 REDUZIDO: 24→20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32, // 🔧 REDUZIDO: 40→32
            height: 3, // 🔧 REDUZIDO: 4→3
            margin: const EdgeInsets.symmetric(vertical: 12), // 🔧 REDUZIDO: 16→12
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
            child: Text(
              'Escolha um Treino',
              style: TextStyle(
                fontSize: 18, // 🔧 REDUZIDO: 24→18 (-25%)
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          
          const SizedBox(height: 16), // 🔧 REDUZIDO: 20→16
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16), // 🔧 REDUZIDO: 20→16
              itemCount: _treinosRecentes.length,
              itemBuilder: (context, index) {
                final treino = _treinosRecentes[index];
                return _buildTreinoListTile(treino, index);
              },
            ),
          ),
          
          const SizedBox(height: 24), // 🔧 REDUZIDO: 30→24
        ],
      ),
    );
  }

  Widget _buildTreinoListTile(TreinoModel treino, int index) {
    final colors = [
      const Color(0xFF4ECDC4),
      const Color(0xFF667EEA),
      const Color(0xFFFF6B6B),
      const Color(0xFF9D50BB),
    ];
    
    final color = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // 🔧 REDUZIDO: 12→10
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // 🔧 REDUZIDO: 16→12
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12), // 🔧 REDUZIDO: 16→12
        leading: Container(
          width: 44, // 🔧 REDUZIDO: 56→44
          height: 44, // 🔧 REDUZIDO: 56→44
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12), // 🔧 REDUZIDO: 16→12
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: color,
            size: 20, // 🔧 REDUZIDO: 24→20
          ),
        ),
        title: Text(
          treino.nomeTreino,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14, // 🔧 REDUZIDO: 16→14 (-12%)
          ),
        ),
        subtitle: Text(
          '${treino.exercicios.length} exercícios • ${treino.tipoTreino}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12, // 🔧 REDUZIDO: 14→12 (-14%)
          ),
        ),
        trailing: Container(
          width: 32, // 🔧 REDUZIDO: 40→32
          height: 32, // 🔧 REDUZIDO: 40→32
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: color,
            size: 18, // 🔧 REDUZIDO: 24→18
          ),
        ),
        onTap: () => Navigator.pop(context, treino),
      ),
    );
  }

  void _showComingSoon(String feature) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature será implementado em breve!',
          style: const TextStyle(fontSize: 14), // 🔧 ADICIONADO
        ),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // 🔧 REDUZIDO: 12→10
        margin: const EdgeInsets.all(12), // 🔧 REDUZIDO: 16→12
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Treino App',
          style: TextStyle(
            fontSize: 18, // 🔧 REDUZIDO: 24→18 (-25%)
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3748),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Container(
              width: 36, // 🔧 REDUZIDO: 40→36
              height: 36, // 🔧 REDUZIDO: 40→36
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFF6B6B),
                size: 18, // 🔧 REDUZIDO: 20→18
              ),
            ),
            tooltip: 'Sair',
          ),
          const SizedBox(width: 6), // 🔧 REDUZIDO: 8→6
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _carregarTreinosRecentes,
          color: const Color(0xFF4ECDC4),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATUS DO USUÁRIO
                _buildUserStatus(),
                
                // AÇÃO PRINCIPAL
                _buildMainActionSection(),
                
                const SizedBox(height: 24), // 🔧 REDUZIDO: 32→24
                
                // TREINOS RECENTES
                _buildTreinosRecentes(),
                
                const SizedBox(height: 24), // 🔧 REDUZIDO: 32→24
                
                // FUNCIONALIDADES
                _buildFuncionalidades(),
                
                const SizedBox(height: 30), // 🔧 REDUZIDO: 40→30
              ],
            ),
          ),
        ),
      ),
    );
  }
}