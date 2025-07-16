import 'package:flutter/material.dart';
import '../../screens/treino/meus_treinos_screen.dart';
import '../../screens/treino/detalhes_treino_screen.dart';
import '../../screens/treino/criar_treino_screen.dart';
import '../../models/treino_model.dart';
import 'app_routes.dart';

/// Classe profissional para gerenciar navegação de treinos
class TreinoRoutes {
  
  // ===== NAVEGAÇÃO SIMPLES =====
  
  /// Navegar para Meus Treinos
  static Future<void> goToMeusTreinos(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.meusTreinos);
  }

  /// Navegar para Criar Treino
  static Future<TreinoModel?> goToCriarTreino(BuildContext context) async {
    final resultado = await Navigator.pushNamed<TreinoModel>(
      context, 
      AppRoutes.criarTreino,
    );
    return resultado;
  }

  /// Navegar para Detalhes do Treino
  static Future<void> goToDetalhesTreino(
    BuildContext context, 
    TreinoModel treino,
  ) async {
    await Navigator.pushNamed(
      context, 
      AppRoutes.detalhesTreino,
      arguments: treino,
    );
  }

  // ===== NAVEGAÇÃO COM REPLACEMENT =====

  /// Substituir tela atual por Meus Treinos
  static Future<void> replaceWithMeusTreinos(BuildContext context) async {
    await Navigator.pushReplacementNamed(context, AppRoutes.meusTreinos);
  }

  /// Voltar para Meus Treinos (limpar stack)
  static Future<void> backToMeusTreinos(BuildContext context) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.meusTreinos,
      (route) => route.settings.name == AppRoutes.home,
    );
  }

  // ===== NAVEGAÇÃO COM FEEDBACK =====

  /// Criar treino com feedback de sucesso
  static Future<void> criarTreinoComFeedback(BuildContext context) async {
    final treinoCriado = await goToCriarTreino(context);
    
    if (treinoCriado != null && context.mounted) {
      _showSuccessSnackBar(
        context,
        'Treino "${treinoCriado.nomeTreino}" criado com sucesso!',
        action: SnackBarAction(
          label: 'Ver Detalhes',
          textColor: Colors.white,
          onPressed: () => goToDetalhesTreino(context, treinoCriado),
        ),
      );
    }
  }

  /// Atualizar treino com feedback
  static Future<void> editarTreinoComFeedback(
    BuildContext context,
    TreinoModel treino,
  ) async {
    // TODO: Implementar quando tiver tela de edição
    _showInfoSnackBar(context, 'Edição será implementada em breve');
  }

  /// Deletar treino com confirmação
  static Future<void> deletarTreinoComConfirmacao(
    BuildContext context,
    TreinoModel treino,
  ) async {
    final shouldDelete = await _showDeleteDialog(context, treino);
    
    if (shouldDelete == true) {
      // TODO: Implementar deleção no provider
      _showSuccessSnackBar(
        context,
        'Treino "${treino.nomeTreino}" removido',
      );
    }
  }

  // ===== NAVEGAÇÃO COM VERIFICAÇÕES =====

  /// Navegar verificando autenticação
  static Future<void> goToMeusTreinosSecure(BuildContext context) async {
    if (await _checkAuth(context)) {
      await goToMeusTreinos(context);
    }
  }

  /// Navegar verificando premium
  static Future<void> goToCriarTreinoSecure(BuildContext context) async {
    if (await _checkAuth(context) && await _checkPremium(context)) {
      await goToCriarTreino(context);
    }
  }

  // ===== NAVEGAÇÃO COM ANIMAÇÕES CUSTOMIZADAS =====

  /// Slide da direita
  static Future<void> goToMeusTreinosWithSlide(BuildContext context) async {
    await Navigator.push(
      context,
      _slideFromRight(const MeusTreinosScreen()),
    );
  }

  /// Fade transition
  static Future<void> goToDetalhesTreinoWithFade(
    BuildContext context,
    TreinoModel treino,
  ) async {
    await Navigator.push(
      context,
      _fadeTransition(DetalhesTreinoScreen(treino: treino)),
    );
  }

  /// Scale transition
  static Future<TreinoModel?> goToCriarTreinoWithScale(BuildContext context) async {
    final resultado = await Navigator.push<TreinoModel>(
      context,
      _scaleTransition(const CriarTreinoScreen()),
    );
    return resultado;
  }

  // ===== MÉTODOS UTILITÁRIOS PRIVADOS =====

  /// Verificar autenticação
  static Future<bool> _checkAuth(BuildContext context) async {
    // TODO: Implementar verificação com AuthProvider
    return true; // Por enquanto sempre true
  }

  /// Verificar acesso premium
  static Future<bool> _checkPremium(BuildContext context) async {
    // TODO: Implementar verificação premium
    return true; // Por enquanto sempre true
  }

  /// Mostrar SnackBar de sucesso
  static void _showSuccessSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }

  /// Mostrar SnackBar de informação
  static void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Mostrar diálogo de confirmação de deleção
  static Future<bool?> _showDeleteDialog(
    BuildContext context,
    TreinoModel treino,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Remoção'),
        content: Text('Tem certeza que deseja remover o treino "${treino.nomeTreino}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===== ANIMAÇÕES CUSTOMIZADAS =====

  /// Slide da direita
  static Route<T> _slideFromRight<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  /// Fade transition
  static Route<T> _fadeTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Scale transition
  static Route<T> _scaleTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
          child: child,
        );
      },
    );
  }

  // ===== NAVEGAÇÃO EM LOTE =====

  /// Navegar para múltiplas telas em sequência
  static Future<void> goToTreinoFlow(
    BuildContext context,
    List<String> routes,
  ) async {
    for (final route in routes) {
      await Navigator.pushNamed(context, route);
    }
  }

  /// Reset navigation stack e ir para Meus Treinos
  static Future<void> resetToMeusTreinos(BuildContext context) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.meusTreinos,
      (route) => false,
    );
  }
}