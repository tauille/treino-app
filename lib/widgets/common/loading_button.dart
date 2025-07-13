import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Size? minimumSize;
  final Size? maximumSize;
  final String? loadingText;
  final Widget? loadingWidget;
  final Duration animationDuration;
  final bool fullWidth;

  const LoadingButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.minimumSize,
    this.maximumSize,
    this.loadingText,
    this.loadingWidget,
    this.animationDuration = const Duration(milliseconds: 200),
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF667eea),
        foregroundColor: foregroundColor ?? Colors.white,
        disabledBackgroundColor: disabledBackgroundColor ?? Colors.grey[400],
        disabledForegroundColor: disabledForegroundColor ?? Colors.grey[600],
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        elevation: elevation ?? 2,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        minimumSize: minimumSize,
        maximumSize: maximumSize,
      ),
      child: AnimatedSwitcher(
        duration: animationDuration,
        child: isLoading ? _buildLoadingContent() : _buildNormalContent(),
      ),
    );

    if (fullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildLoadingContent() {
    return Row(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loadingWidget != null) 
          loadingWidget!
        else
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        const SizedBox(width: 12),
        Text(loadingText ?? 'Carregando...'),
      ],
    );
  }

  Widget _buildNormalContent() {
    return Container(
      key: const ValueKey('normal'),
      child: child,
    );
  }

  // ===== FACTORY CONSTRUCTORS =====

  /// Botão primário (destaque)
  factory LoadingButton.primary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF667eea),
      foregroundColor: Colors.white,
      loadingText: loadingText,
      fullWidth: fullWidth,
      padding: padding,
    );
  }

  /// Botão secundário
  factory LoadingButton.secondary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: Colors.grey[600],
      foregroundColor: Colors.white,
      loadingText: loadingText,
      fullWidth: fullWidth,
      padding: padding,
    );
  }

  /// Botão de sucesso (verde)
  factory LoadingButton.success({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      loadingText: loadingText,
      fullWidth: fullWidth,
      padding: padding,
    );
  }

  /// Botão de perigo (vermelho)
  factory LoadingButton.danger({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      loadingText: loadingText,
      fullWidth: fullWidth,
      padding: padding,
    );
  }

  /// Botão de aviso (laranja)
  factory LoadingButton.warning({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      loadingText: loadingText,
      fullWidth: fullWidth,
      padding: padding,
    );
  }

  /// Botão grande (padding maior)
  factory LoadingButton.large({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    Color? backgroundColor,
    String? loadingText,
    bool fullWidth = true,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? const Color(0xFF667eea),
      loadingText: loadingText,
      fullWidth: fullWidth,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
    );
  }

  /// Botão pequeno (padding menor)
  factory LoadingButton.small({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    Color? backgroundColor,
    String? loadingText,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? const Color(0xFF667eea),
      loadingText: loadingText,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }

  /// Botão com ícone personalizado de loading
  factory LoadingButton.withCustomLoading({
    required VoidCallback? onPressed,
    required Widget child,
    required Widget loadingWidget,
    bool isLoading = false,
    Color? backgroundColor,
    String? loadingText,
    bool fullWidth = false,
  }) {
    return LoadingButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      loadingWidget: loadingWidget,
      loadingText: loadingText,
      fullWidth: fullWidth,
    );
  }
}

// ===== WIDGET OUTLINE LOADING BUTTON =====

class OutlineLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final String? loadingText;
  final bool fullWidth;

  const OutlineLoadingButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.loadingText,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? const Color(0xFF667eea);
    final effectiveTextColor = textColor ?? effectiveBorderColor;

    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveTextColor,
        side: BorderSide(color: effectiveBorderColor),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(loadingText ?? 'Carregando...'),
              ],
            )
          : child,
    );

    if (fullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

// ===== WIDGET TEXT LOADING BUTTON =====

class TextLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final String? loadingText;

  const TextLoadingButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.textColor,
    this.padding,
    this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? const Color(0xFF667eea),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? const Color(0xFF667eea),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(loadingText ?? 'Carregando...'),
              ],
            )
          : child,
    );
  }
}