import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  
  // Dados do usuário (mock)
  Map<String, dynamic> _userData = {
    'nome': 'João Silva',
    'email': 'joao.silva@email.com',
    'isPremium': false,
    'dataIngresso': DateTime.now().subtract(const Duration(days: 45)),
    'avatar': null,
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Configurar animações
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  /// Carregar dados do usuário
  Future<void> _carregarDadosUsuario() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carregamento
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Carregar dados reais do provider/API
      setState(() {
        // _userData já está definido acima
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _carregarDadosUsuario,
            color: const Color(0xFF4ECDC4),
            backgroundColor: const Color(0xFF2A2D3A),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header com perfil
                  _buildHeaderPerfil(),
                  
                  const SizedBox(height: 24),
                  
                  // Seção de conta
                  _buildSecaoConta(),
                  
                  const SizedBox(height: 24),
                  
                  // Seção de configurações
                  _buildSecaoConfiguracoes(),
                  
                  const SizedBox(height: 24),
                  
                  // Seção de suporte
                  _buildSecaoSuporte(),
                  
                  const SizedBox(height: 24),
                  
                  // Botão de sair
                  _buildBotaoSair(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header com perfil do usuário
  Widget _buildHeaderPerfil() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4ECDC4),
                    width: 3,
                  ),
                ),
                child: _userData['avatar'] != null
                  ? ClipOval(
                      child: Image.network(
                        _userData['avatar'],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: const Color(0xFF4ECDC4),
                    ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _editarFoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1A1D29),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nome
          Text(
            _userData['nome'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            _userData['email'],
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Badge Premium
          if (_userData['isPremium'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _upgradeParaPremium,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4ECDC4),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upgrade,
                      color: Color(0xFF4ECDC4),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Upgrade para Premium',
                      style: TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Seção da conta
  Widget _buildSecaoConta() {
    return _buildSecao(
      'Conta',
      [
        _buildItemMenu(
          icon: Icons.person_outline,
          titulo: 'Editar Perfil',
          subtitulo: 'Nome, email e informações pessoais',
          onTap: _editarPerfil,
        ),
        _buildItemMenu(
          icon: Icons.lock_outline,
          titulo: 'Alterar Senha',
          subtitulo: 'Manter sua conta segura',
          onTap: _alterarSenha,
        ),
        _buildItemMenu(
          icon: Icons.notifications,
          titulo: 'Notificações',
          subtitulo: 'Lembretes e alertas',
          onTap: _configurarNotificacoes,
          trailing: Switch(
            value: true, // TODO: pegar valor real
            onChanged: (value) {
              // TODO: implementar
            },
            activeColor: const Color(0xFF4ECDC4),
          ),
        ),
      ],
    );
  }

  /// Seção de configurações
  Widget _buildSecaoConfiguracoes() {
    return _buildSecao(
      'Configurações',
      [
        _buildItemMenu(
          icon: Icons.fitness_center_outlined,
          titulo: 'Preferências de Treino',
          subtitulo: 'Unidades, dificuldade padrão',
          onTap: _configurarTreinos,
        ),
        _buildItemMenu(
          icon: Icons.palette_outlined,
          titulo: 'Tema',
          subtitulo: 'Aparência do app',
          onTap: _configurarTema,
        ),
        _buildItemMenu(
          icon: Icons.language_outlined,
          titulo: 'Idioma',
          subtitulo: 'Português (Brasil)',
          onTap: _configurarIdioma,
        ),
        _buildItemMenu(
          icon: Icons.backup_outlined,
          titulo: 'Backup',
          subtitulo: 'Sincronizar dados na nuvem',
          onTap: _configurarBackup,
        ),
      ],
    );
  }

  /// Seção de suporte
  Widget _buildSecaoSuporte() {
    return _buildSecao(
      'Suporte',
      [
        _buildItemMenu(
          icon: Icons.help_outline,
          titulo: 'Central de Ajuda',
          subtitulo: 'FAQ e tutoriais',
          onTap: _abrirAjuda,
        ),
        _buildItemMenu(
          icon: Icons.bug_report_outlined,
          titulo: 'Reportar Problema',
          subtitulo: 'Bugs e sugestões',
          onTap: _reportarProblema,
        ),
        _buildItemMenu(
          icon: Icons.star_outline,
          titulo: 'Avaliar App',
          subtitulo: 'Deixe sua avaliação',
          onTap: _avaliarApp,
        ),
        _buildItemMenu(
          icon: Icons.info_outline,
          titulo: 'Sobre',
          subtitulo: 'Versão 1.0.0',
          onTap: _mostrarSobre,
        ),
      ],
    );
  }

  /// Construir seção
  Widget _buildSecao(String titulo, List<Widget> itens) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF374151),
                width: 1,
              ),
            ),
            child: Column(
              children: itens.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == itens.length - 1;
                
                return Column(
                  children: [
                    item,
                    if (!isLast)
                      const Divider(
                        color: Color(0xFF374151),
                        height: 1,
                        indent: 60,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Item do menu
  Widget _buildItemMenu({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4ECDC4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Botão de sair
  Widget _buildBotaoSair() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _mostrarDialogoSair,
        icon: const Icon(Icons.logout),
        label: const Text('Sair da Conta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE AÇÃO
  // ============================================================================

  void _editarFoto() {
    // TODO: implementar seleção de foto
    HapticFeedback.lightImpact();
  }

  void _editarPerfil() {
    // TODO: navegar para edição de perfil
    HapticFeedback.lightImpact();
  }

  void _alterarSenha() {
    // TODO: navegar para alteração de senha
    HapticFeedback.lightImpact();
  }

  void _configurarNotificacoes() {
    // TODO: navegar para configurações de notificação
    HapticFeedback.lightImpact();
  }

  void _configurarTreinos() {
    // TODO: navegar para preferências de treino
    HapticFeedback.lightImpact();
  }

  void _configurarTema() {
    // TODO: mostrar seletor de tema
    HapticFeedback.lightImpact();
  }

  void _configurarIdioma() {
    // TODO: mostrar seletor de idioma
    HapticFeedback.lightImpact();
  }

  void _configurarBackup() {
    // TODO: navegar para configurações de backup
    HapticFeedback.lightImpact();
  }

  void _abrirAjuda() {
    // TODO: abrir central de ajuda
    HapticFeedback.lightImpact();
  }

  void _reportarProblema() {
    // TODO: abrir formulário de reporte
    HapticFeedback.lightImpact();
  }

  void _avaliarApp() {
    // TODO: abrir loja de apps para avaliação
    HapticFeedback.lightImpact();
  }

  void _mostrarSobre() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: Color(0xFF4ECDC4),
            ),
            SizedBox(width: 8),
            Text(
              'Treino App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão: 1.0.0',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            SizedBox(height: 8),
            Text(
              'Desenvolvido com ❤️ para ajudar você a alcançar seus objetivos fitness.',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }

  void _upgradeParaPremium() {
    // TODO: navegar para tela de upgrade
    HapticFeedback.lightImpact();
  }

  void _mostrarDialogoSair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sair da conta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sairDaConta();
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _sairDaConta() {
    // TODO: implementar logout
    HapticFeedback.lightImpact();
  }
}