// BONUS: Usar flutter_spinkit que você já tem instalado!
// widgets/common/loading_button_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingButtonEnhanced extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final SpinKitType spinKitType;

  const LoadingButtonEnhanced({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.spinKitType = SpinKitType.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF667eea),
        foregroundColor: foregroundColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        elevation: elevation ?? 2,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        disabledBackgroundColor: Colors.grey[400],
        disabledForegroundColor: Colors.grey[600],
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: _buildSpinKit(),
                ),
                const SizedBox(width: 12),
                const Text('Carregando...'),
              ],
            )
          : child,
    );
  }

  Widget _buildSpinKit() {
    switch (spinKitType) {
      case SpinKitType.circle:
        return const SpinKitCircle(
          color: Colors.white,
          size: 20,
        );
      case SpinKitType.pulse:
        return const SpinKitPulse(
          color: Colors.white,
          size: 20,
        );
      case SpinKitType.fadingCube:
        return const SpinKitFadingCube(
          color: Colors.white,
          size: 20,
        );
      case SpinKitType.wave:
        return const SpinKitWave(
          color: Colors.white,
          size: 20,
        );
      case SpinKitType.threeBounce:
        return const SpinKitThreeBounce(
          color: Colors.white,
          size: 20,
        );
      default:
        return const SpinKitCircle(
          color: Colors.white,
          size: 20,
        );
    }
  }
}

enum SpinKitType {
  circle,
  pulse,
  fadingCube,
  wave,
  threeBounce,
}

// EXEMPLO DE USO:
/*
LoadingButtonEnhanced(
  onPressed: _criarTreino,
  isLoading: treinoProvider.isLoading,
  spinKitType: SpinKitType.pulse, // Animação diferente!
  child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_circle),
      SizedBox(width: 8),
      Text('Criar Treino'),
    ],
  ),
)
*/