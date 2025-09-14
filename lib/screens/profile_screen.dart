import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_google.dart';
import '../../core/theme/sport_theme.dart';
import 'debug_assets_screen.dart';

/// 👤 Tela de Perfil e Configurações
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  /// Fazer logout
  Future<void> _signOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirmar Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: SportColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SportColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
      await authProvider.signOut();
    }
  }

  /// Mostrar coming soon
  void _showComingSoon(String feature) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature será implementado em breve!'),
        backgroundColor: SportColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Navegar para debug de assets
  void _navigateToDebugAssets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DebugAssetsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<AuthProviderGoogle>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              if (user == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: SportColors.primary,
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Perfil',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // INFO DO USUÁRIO
                    _buildUserInfo(user),
                    
                    const SizedBox(height: 32),
                    
                    // STATUS PREMIUM
                    _buildPremiumStatus(user),
                    
                    const SizedBox(height: 32),
                    
                    // CONFIGURAÇÕES
                    _buildConfiguracoes(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Info do usuário
  Widget _buildUserInfo(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SportColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: SportColors.primaryGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: SportColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nome
          Text(
            user.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: SportColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Membro desde
          ModernSportWidgets.statusBadge(
            text: 'Membro desde ${_formatDate(user.createdAt)}',
            color: SportColors.primary,
          ),
        ],
      ),
    );
  }

  /// Status premium
  Widget _buildPremiumStatus(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: user.hasAccess 
            ? SportColors.premiumGradient
            : SportColors.energyGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (user.hasAccess 
                ? SportColors.accent 
                : SportColors.warning).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            user.isPremium 
                ? Icons.diamond_rounded
                : user.isInTrial 
                    ? Icons.schedule_rounded
                    : Icons.lock_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            user.statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            user.isPremium
                ? 'Acesso completo a todas as funcionalidades'
                : user.isInTrial
                    ? 'Aproveite seus dias de teste gratuito'
                    : 'Assine para ter acesso completo',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (user.isInTrial) ...[
            const SizedBox(height: 12),
            Text(
              'Expira em ${user.trialExpiresAt?.day}/${user.trialExpiresAt?.month}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          
          if (!user.hasAccess) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'ASSINAR AGORA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Configurações
  Widget _buildConfiguracoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚙️ CONFIGURAÇÕES',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildConfigItem(
          icon: Icons.notifications_rounded,
          title: 'Notificações',
          subtitle: 'Lembretes de treino e progresso',
          onTap: () => _showComingSoon('Notificações'),
        ),
        
        _buildConfigItem(
          icon: Icons.volume_up_rounded,
          title: 'Sons e Vibração',
          subtitle: 'Feedback durante os treinos',
          onTap: () => _showComingSoon('Sons e Vibração'),
        ),
        
        _buildConfigItem(
          icon: Icons.cloud_sync_rounded,
          title: 'Backup e Sincronização',
          subtitle: 'Dados seguros na nuvem',
          onTap: () => _showComingSoon('Backup'),
        ),
        
        _buildConfigItem(
          icon: Icons.bug_report_rounded,
          title: 'Debug Assets',
          subtitle: 'Testar sistema de imagens',
          onTap: _navigateToDebugAssets,
          isDebug: true,
        ),
        
        _buildConfigItem(
          icon: Icons.help_rounded,
          title: 'Ajuda e Suporte',
          subtitle: 'Tire suas dúvidas',
          onTap: () => _showComingSoon('Suporte'),
        ),
        
        const SizedBox(height: 16),
        
        _buildConfigItem(
          icon: Icons.logout_rounded,
          title: 'Sair da Conta',
          subtitle: 'Fazer logout do aplicativo',
          onTap: _signOut,
          isDestructive: true,
        ),
      ],
    );
  }

  /// Item de configuração
  Widget _buildConfigItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isDebug = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SportColors.grey200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDestructive 
                ? SportColors.error 
                : isDebug 
                    ? Colors.orange 
                    : SportColors.primary)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive 
                ? SportColors.error 
                : isDebug 
                    ? Colors.orange 
                    : SportColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? SportColors.error : SportColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: SportColors.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: SportColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Formatar data
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}