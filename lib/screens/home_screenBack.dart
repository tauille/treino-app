import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/google_auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'treino/criar_treino_screen.dart';

/// Tela Home - Dashboard principal (estrutura básica)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Configurar status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    _loadUserData();
    
    // 🚨 DEBUG ÓBVIO - Se você ver isso, o código foi atualizado!
    print('🚨🚨🚨 CÓDIGO ATUALIZADO! VERSÃO DEBUG 2.0 🚨🚨🚨');
  }

  /// Carregar dados do usuário
  void _loadUserData() {
    setState(() {
      _user = GoogleAuthService().currentUser;
    });
    
    // DEBUG: Verificar se usuário foi carregado
    print('🔍 DEBUG: Usuário carregado: ${_user?.name ?? 'NULL'}');
    print('🔍 DEBUG: Build será executado...');
  }

  /// Fazer logout
  Future<void> _signOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      await GoogleAuthService().signOut();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  /// Widget do status do usuário
  Widget _buildUserStatus() {
    if (_user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _user!.hasAccess
              ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
              : [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _user!.isPremium ? Icons.star : Icons.access_time,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.isPremium 
                          ? 'Premium Ativo' 
                          : _user!.isInTrial
                              ? 'Trial Ativo'
                              : 'Trial Expirado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _user!.isPremium
                          ? 'Acesso total aos treinos'
                          : _user!.isInTrial
                              ? '${_user!.trialDaysLeft} dias restantes'
                              : 'Assine para continuar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_user!.hasAccess)
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implementar tela de assinatura
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tela de assinatura será implementada'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Assinar'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget de funcionalidades em breve
  Widget _buildComingSoonCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667eea),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Em breve',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.amber[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🚨 Widget para card funcional (clicável) - COM DEBUG VISUAL
  Widget _buildFunctionalCard(String title, String description, IconData icon, VoidCallback onTap) {
    print('🚨 DEBUG: Construindo _buildFunctionalCard para: $title');
    
    return GestureDetector(
      onTap: () {
        print('🚨🚨🚨 CARD FUNCIONAL CLICADO: $title');
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // 🚨 COR ROSA CHOQUE PARA DEBUG - SE VER ISSO, CÓDIGO FUNCIONOU!
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.pink, width: 3), // 🚨 BORDA ROSA
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3), // 🚨 SOMBRA ROSA
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2), // 🚨 ÍCONE ROSA
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: Colors.pink[700], // 🚨 ÍCONE ROSA
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚨 $title (DEBUG)', // 🚨 TÍTULO COM DEBUG
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink[700], // 🚨 TEXTO ROSA
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.pink[600], // 🚨 DESCRIÇÃO ROSA
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8), // 🚨 BADGE VERDE FORTE
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🚨 FUNCIONA!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🚨 DEBUG: Build executado - VERSÃO 2.0 - isLoading: $_isLoading, user: ${_user?.name}');
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${_user?.name.split(' ').first ?? 'Usuário'}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const Text(
              '🚨 DEBUG MODE 2.0', // 🚨 INDICADOR VISUAL
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF667eea),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATUS DO USUÁRIO
                  _buildUserStatus(),
                  
                  // TÍTULO SEÇÃO
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Funcionalidades',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  
                  // CARDS DE FUNCIONALIDADES
                  _buildComingSoonCard(
                    'Meus Treinos',
                    'Visualize e gerencie seus treinos personalizados',
                    Icons.fitness_center,
                  ),
                  
                  // 🚨 CARD FUNCIONAL - CRIAR TREINO COM DEBUG VISUAL
                  _buildFunctionalCard(
                    'Criar Treino',
                    'Monte seu próprio treino com exercícios customizados',
                    Icons.add_circle_outline,
                    () {
                      print('🚨🚨🚨 CRIAR TREINO CLICADO! Navegando...');
                      
                      // 🚨 MOSTRAR DIALOG DE DEBUG PRIMEIRO
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('🚨 DEBUG'),
                          content: const Text('Card funcional foi clicado! Agora vai navegar.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                try {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CriarTreinoScreen(),
                                    ),
                                  );
                                  print('✅ Navegação para CriarTreinoScreen iniciada');
                                } catch (e) {
                                  print('❌ Erro na navegação: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao abrir tela: $e')),
                                  );
                                }
                              },
                              child: const Text('Navegar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  _buildComingSoonCard(
                    'Histórico',
                    'Acompanhe seu progresso e evolução',
                    Icons.analytics,
                  ),
                  
                  _buildComingSoonCard(
                    'Configurações',
                    'Personalize sua experiência no app',
                    Icons.settings,
                  ),

                  // INFORMAÇÕES ADICIONAIS
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'App em Desenvolvimento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🚨 MODO DEBUG ATIVO - Se você vê este texto, '
                          'o código foi atualizado com sucesso!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}