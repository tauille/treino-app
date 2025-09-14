import 'dart:io';
import 'package:flutter/material.dart';
import '../core/helpers/exercise_assets_helper.dart';

class ExerciseImageWidget extends StatefulWidget {
  final String nomeExercicio;
  final String? grupoMuscular; // Adicionado para fallbacks
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final IconData? placeholderIcon;
  final bool showName;
  final TextStyle? nameStyle;

  const ExerciseImageWidget({
    Key? key,
    required this.nomeExercicio,
    this.grupoMuscular,
    this.width,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor,
    this.placeholderIcon = Icons.fitness_center,
    this.showName = false,
    this.nameStyle,
  }) : super(key: key);

  @override
  State<ExerciseImageWidget> createState() => _ExerciseImageWidgetState();
}

class _ExerciseImageWidgetState extends State<ExerciseImageWidget> {
  String? _assetPath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarImagem();
  }

  @override
  void didUpdateWidget(ExerciseImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nomeExercicio != widget.nomeExercicio) {
      _carregarImagem();
    }
  }

  Future<void> _carregarImagem() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _assetPath = null;
    });

    try {
      // Usar o sistema que funciona na tela de debug
      final assetPath = ExerciseAssetsHelper.resolveExerciseAsset(
        widget.nomeExercicio,
        muscleGroup: widget.grupoMuscular,
      );

      if (assetPath != null) {
        // Verificar se o asset existe
        final exists = await ExerciseAssetsHelper.assetExists(assetPath);
        
        if (mounted) {
          setState(() {
            _assetPath = exists ? assetPath : null;
            _isLoading = false;
            _hasError = !exists;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _assetPath = null;
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar asset para ${widget.nomeExercicio}: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget imageWidget;

    if (_isLoading) {
      imageWidget = _buildLoadingWidget(theme);
    } else if (_hasError || _assetPath == null) {
      imageWidget = _buildPlaceholderWidget(theme);
    } else {
      imageWidget = _buildImageWidget();
    }

    // Aplicar bordas se especificado
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    // Container principal
    Widget container = Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.borderRadius != null
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
      child: imageWidget,
    );

    // Adicionar nome se solicitado
    if (widget.showName) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          container,
          const SizedBox(height: 4),
          Text(
            widget.nomeExercicio,
            style: widget.nameStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return container;
  }

  Widget _buildImageWidget() {
    // Usar Image.asset em vez de Image.file
    return Image.asset(
      _assetPath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        print('Erro ao exibir asset ${_assetPath}: $error');
        return _buildErrorWidget(Theme.of(context));
      },
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[100],
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.primaryColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(ThemeData theme) {
    final color = widget.placeholderColor ?? Colors.grey[400];
    final iconSize = widget.height != null 
        ? (widget.height! * 0.4).clamp(24.0, 48.0) 
        : 32.0;

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.placeholderIcon,
            color: color,
            size: iconSize,
          ),
          if (widget.height != null && widget.height! > 60) ...[
            const SizedBox(height: 4),
            Text(
              'Sem imagem',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    final iconSize = widget.height != null 
        ? (widget.height! * 0.4).clamp(24.0, 48.0) 
        : 32.0;

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.red[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: iconSize,
          ),
          if (widget.height != null && widget.height! > 60) ...[
            const SizedBox(height: 4),
            Text(
              'Erro',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget especializado para lista de exercícios
class ExerciseListImageWidget extends StatelessWidget {
  final String nomeExercicio;
  final String? grupoMuscular;

  const ExerciseListImageWidget({
    Key? key,
    required this.nomeExercicio,
    this.grupoMuscular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseImageWidget(
      nomeExercicio: nomeExercicio,
      grupoMuscular: grupoMuscular,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      placeholderIcon: Icons.fitness_center,
    );
  }
}

// Widget especializado para detalhes do exercício
class ExerciseDetailImageWidget extends StatelessWidget {
  final String nomeExercicio;
  final String? grupoMuscular;

  const ExerciseDetailImageWidget({
    Key? key,
    required this.nomeExercicio,
    this.grupoMuscular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseImageWidget(
      nomeExercicio: nomeExercicio,
      grupoMuscular: grupoMuscular,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      placeholderIcon: Icons.fitness_center,
      showName: false,
    );
  }
}

// Widget especializado para execução de treino (com animação)
class ExerciseExecutionImageWidget extends StatefulWidget {
  final String nomeExercicio;
  final String? grupoMuscular;

  const ExerciseExecutionImageWidget({
    Key? key,
    required this.nomeExercicio,
    this.grupoMuscular,
  }) : super(key: key);

  @override
  State<ExerciseExecutionImageWidget> createState() => _ExerciseExecutionImageWidgetState();
}

class _ExerciseExecutionImageWidgetState extends State<ExerciseExecutionImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animação pulsante suave
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ExerciseImageWidget(
            nomeExercicio: widget.nomeExercicio,
            grupoMuscular: widget.grupoMuscular,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(16),
            placeholderIcon: Icons.directions_run,
            placeholderColor: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}