import 'package:flutter/material.dart';

/// Widget para mostrar estados vazios com ícone, título e ação
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 64.0,
    this.padding,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone
            Container(
              width: iconSize + 32,
              height: iconSize + 32,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[400])!.withOpacity(0.1),
                borderRadius: BorderRadius.circular((iconSize + 32) / 2),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.grey[400],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Mensagem
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Ação
            if (customAction != null)
              customAction!
            else if (actionText != null && onActionPressed != null)
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Estados vazios pré-definidos para diferentes cenários
class EmptyStates {
  /// Estado vazio para treinos
  static Widget workouts({
    VoidCallback? onCreateWorkout,
  }) {
    return EmptyState(
      icon: Icons.fitness_center,
      title: 'Nenhum treino ainda',
      message: 'Que tal criar seu primeiro treino personalizado?',
      actionText: 'Criar Treino',
      onActionPressed: onCreateWorkout,
      iconColor: const Color(0xFF667eea),
    );
  }

  /// Estado vazio para exercícios
  static Widget exercises({
    VoidCallback? onAddExercise,
  }) {
    return EmptyState(
      icon: Icons.add_circle_outline,
      title: 'Nenhum exercício adicionado',
      message: 'Adicione exercícios para montar seu treino',
      actionText: 'Adicionar Exercício',
      onActionPressed: onAddExercise,
      iconColor: const Color(0xFF667eea),
    );
  }

  /// Estado vazio para histórico
  static Widget history({
    VoidCallback? onStartWorkout,
  }) {
    return EmptyState(
      icon: Icons.history,
      title: 'Sem histórico de treinos',
      message: 'Comece a treinar para ver seu progresso aqui',
      actionText: 'Iniciar Treino',
      onActionPressed: onStartWorkout,
      iconColor: Colors.orange,
    );
  }

  /// Estado vazio para resultados de busca
  static Widget searchResults({
    required String query,
    VoidCallback? onClearSearch,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Nenhum resultado encontrado',
      message: 'Não encontramos resultados para "$query".\nTente outros termos de busca.',
      actionText: 'Limpar Busca',
      onActionPressed: onClearSearch,
      iconColor: Colors.grey,
    );
  }

  /// Estado de erro de conexão
  static Widget connectionError({
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'Sem conexão',
      message: 'Verifique sua conexão com a internet e tente novamente',
      actionText: 'Tentar Novamente',
      onActionPressed: onRetry,
      iconColor: Colors.red,
    );
  }

  /// Estado de erro genérico
  static Widget error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Algo deu errado',
      message: message ?? 'Ocorreu um erro inesperado. Tente novamente.',
      actionText: 'Tentar Novamente',
      onActionPressed: onRetry,
      iconColor: Colors.red,
    );
  }

  /// Estado de manutenção
  static Widget maintenance() {
    return const EmptyState(
      icon: Icons.build,
      title: 'Em manutenção',
      message: 'Estamos melhorando a experiência para você.\nVoltaremos em breve!',
      iconColor: Colors.orange,
    );
  }

  /// Estado para funcionalidade não disponível
  static Widget notAvailable({
    String? feature,
    VoidCallback? onUpgrade,
  }) {
    return EmptyState(
      icon: Icons.lock_outline,
      title: 'Funcionalidade Premium',
      message: feature != null
          ? '$feature está disponível apenas para usuários premium'
          : 'Esta funcionalidade está disponível apenas para usuários premium',
      actionText: 'Fazer Upgrade',
      onActionPressed: onUpgrade,
      iconColor: Colors.amber,
    );
  }

  /// Estado para trial expirado
  static Widget trialExpired({
    VoidCallback? onSubscribe,
  }) {
    return EmptyState(
      icon: Icons.access_time,
      title: 'Trial Expirado',
      message: 'Seu período de teste gratuito acabou.\nAssine para continuar aproveitando todos os recursos.',
      actionText: 'Assinar Premium',
      onActionPressed: onSubscribe,
      iconColor: Colors.red,
    );
  }

  /// Estado de sucesso
  static Widget success({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.check_circle_outline,
      title: title,
      message: message,
      actionText: actionText,
      onActionPressed: onAction,
      iconColor: Colors.green,
    );
  }

  /// Estado de onboarding/boas-vindas
  static Widget welcome({
    String? userName,
    VoidCallback? onGetStarted,
  }) {
    return EmptyState(
      icon: Icons.waving_hand,
      title: userName != null ? 'Bem-vindo, $userName!' : 'Bem-vindo!',
      message: 'Vamos começar sua jornada fitness?\nCrie seu primeiro treino personalizado.',
      actionText: 'Começar',
      onActionPressed: onGetStarted,
      iconColor: const Color(0xFF667eea),
    );
  }
}

/// Widget de loading state
class LoadingState extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingState({
    super.key,
    this.message,
    this.size = 48.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).primaryColor,
              strokeWidth: 3,
            ),
          ),
          
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para estado de carregamento com skeleton
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? Colors.grey[300]!,
                widget.highlightColor ?? Colors.grey[100]!,
                widget.baseColor ?? Colors.grey[300]!,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}