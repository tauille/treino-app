import 'package:flutter/material.dart';
import '../../screens/treino/treinos_library_screen.dart';
import '../../screens/treino/detalhes_treino_screen.dart';
import '../../screens/treino/criar_treino_screen.dart';
import '../../screens/treino/treino_preparacao_screen.dart';
import '../../screens/treino/execucao_treino_screen.dart'; // ✅ CORRIGIDO
import '../../models/treino_model.dart';
import 'app_routes.dart';

/// Classe simplificada para gerenciar navegação de treinos
class TreinoRoutes {
  
  // ===== NAVEGACAO BASICA =====
  
  /// Navegar para Biblioteca de Treinos
  static Future<void> goToBiblioteca(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.biblioteca);
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

  // ===== EXECUCAO DE TREINO =====

  /// Navegar para Preparação do Treino
  static Future<void> goToTreinoPreparacao(
    BuildContext context, 
    TreinoModel treino,
  ) async {
    await Navigator.pushNamed(
      context, 
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }

  /// Navegar para Execução do Treino
  static Future<void> goToTreinoExecucao(
    BuildContext context, 
    TreinoModel treino,
  ) async {
    await Navigator.pushNamed(
      context, 
      AppRoutes.treinoExecucao,
      arguments: treino,
    );
  }

  /// Iniciar treino completo (preparação + execução)
  static Future<void> iniciarTreino(
    BuildContext context,
    TreinoModel treino,
  ) async {
    // Verificar se treino tem exercícios
    if (treino.exercicios.isEmpty) {
      _showError(context, 'Este treino não possui exercícios cadastrados');
      return;
    }
    
    _showInfo(context, 'Preparando treino "${treino.nomeTreino}"...');
    await goToTreinoPreparacao(context, treino);
  }

  /// Continuar treino direto para execução
  static Future<void> continuarTreino(
    BuildContext context,
    TreinoModel treino,
  ) async {
    _showInfo(context, 'Continuando treino "${treino.nomeTreino}"...');
    await goToTreinoExecucao(context, treino);
  }

  // ===== NAVEGACAO COM FEEDBACK =====

  /// Criar treino com feedback de sucesso
  static Future<void> criarTreinoComFeedback(BuildContext context) async {
    final treinoCriado = await goToCriarTreino(context);
    
    if (treinoCriado != null && context.mounted) {
      _showSuccess(
        context,
        'Treino "${treinoCriado.nomeTreino}" criado com sucesso!',
        action: () => goToDetalhesTreino(context, treinoCriado),
        actionLabel: 'Ver Detalhes',
      );
    }
  }

  /// Finalizar treino e voltar para biblioteca
  static Future<void> finalizarTreino(BuildContext context) async {
    _showSuccess(
      context,
      'Treino finalizado com sucesso!',
      action: () => Navigator.pushNamed(context, AppRoutes.historico),
      actionLabel: 'Ver Histórico',
    );
    
    // Voltar para biblioteca
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.biblioteca,
      (route) => route.settings.name == AppRoutes.main,
    );
  }

  /// Deletar treino com confirmação
  static Future<void> deletarTreinoComConfirmacao(
    BuildContext context,
    TreinoModel treino,
  ) async {
    final shouldDelete = await _showConfirmDialog(
      context,
      'Confirmar Remoção',
      'Tem certeza que deseja remover o treino "${treino.nomeTreino}"?',
    );
    
    if (shouldDelete == true) {
      // TODO: Implementar deleção no provider
      _showSuccess(context, 'Treino "${treino.nomeTreino}" removido');
    }
  }

  // ===== NAVEGACAO COM REPLACEMENT =====

  /// Voltar para Biblioteca (limpar stack)
  static Future<void> backToBiblioteca(BuildContext context) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.biblioteca,
      (route) => route.settings.name == AppRoutes.main,
    );
  }

  /// Reset navigation stack e ir para Main
  static Future<void> resetToMain(BuildContext context) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
    );
  }

  // ===== HELPERS PRIVADOS =====

  /// Mostrar mensagem de sucesso
  static void _showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? action,
    String? actionLabel,
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
        action: action != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: action,
              )
            : null,
      ),
    );
  }

  /// Mostrar mensagem de informação
  static void _showInfo(BuildContext context, String message) {
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

  /// Mostrar mensagem de erro
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Mostrar diálogo de confirmação
  static Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===== VALIDACOES =====

  /// Verificar se treino é válido para execução
  static bool isValidForExecution(TreinoModel treino) {
    return treino.exercicios.isNotEmpty;
  }

  /// Verificar se usuário pode criar treinos
  static Future<bool> canCreateTraining(BuildContext context) async {
    // TODO: Verificar se usuário tem acesso premium
    return true; // Por enquanto sempre true
  }

  /// Verificar se usuário está autenticado
  static Future<bool> isAuthenticated(BuildContext context) async {
    // TODO: Verificar autenticação com AuthProvider
    return true; // Por enquanto sempre true
  }

  // ===== NAVEGACAO SEGURA =====

  /// Navegar para criação de treino verificando permissões
  static Future<void> goToCriarTreinoSecure(BuildContext context) async {
    if (await isAuthenticated(context) && await canCreateTraining(context)) {
      await criarTreinoComFeedback(context);
    } else {
      _showError(context, 'Acesso premium necessário para criar treinos');
    }
  }

  /// Iniciar treino verificando condições
  static Future<void> iniciarTreinoSecure(
    BuildContext context,
    TreinoModel treino,
  ) async {
    if (!await isAuthenticated(context)) {
      _showError(context, 'Faça login para iniciar treinos');
      return;
    }
    
    if (!isValidForExecution(treino)) {
      _showError(context, 'Este treino não possui exercícios cadastrados');
      return;
    }
    
    await iniciarTreino(context, treino);
  }
}