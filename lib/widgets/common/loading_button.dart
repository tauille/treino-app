import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Botão personalizado com estado de loading
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? loadingWidget;
  final double elevation;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 48.0,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.loadingWidget,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: elevation,
          shadowColor: Colors.black26,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? _buildLoadingWidget()
              : _buildNormalWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return loadingWidget ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: SpinKitFadingCircle(
                color: foregroundColor ?? Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Carregando...',
              style: textStyle,
            ),
          ],
        );
  }

  Widget _buildNormalWidget() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    } else {
      return Text(text, style: textStyle);
    }
  }
}

/// Botão outline com loading
class LoadingOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const LoadingOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;
    final effectiveBorderColor = borderColor ?? theme.primaryColor;
    final effectiveTextColor = textColor ?? theme.primaryColor;
    
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? _buildLoadingWidget(effectiveTextColor)
              : _buildNormalWidget(effectiveTextColor),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: SpinKitFadingCircle(
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Carregando...',
          style: textStyle?.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildNormalWidget(Color color) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle?.copyWith(color: color),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: textStyle?.copyWith(color: color),
      );
    }
  }
}

/// Botão de texto com loading
class LoadingTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? textColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const LoadingTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.textColor,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;
    final effectiveTextColor = textColor ?? theme.primaryColor;
    
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: effectiveTextColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? _buildLoadingWidget(effectiveTextColor)
            : _buildNormalWidget(effectiveTextColor),
      ),
    );
  }

  Widget _buildLoadingWidget(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: SpinKitFadingCircle(
            color: color,
            size: 14,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Carregando...',
          style: textStyle?.copyWith(color: color) ?? 
                 TextStyle(color: color, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNormalWidget(Color color) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: textStyle?.copyWith(color: color) ?? 
                   TextStyle(color: color, fontSize: 14),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: textStyle?.copyWith(color: color) ?? 
               TextStyle(color: color, fontSize: 14),
      );
    }
  }
}

/// Floating Action Button com loading
class LoadingFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool mini;

  const LoadingFAB({
    super.key,
    this.onPressed,
    this.isLoading = false,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    
    return FloatingActionButton(
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
      mini: mini,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? SpinKitFadingCircle(
                color: foregroundColor ?? Colors.white,
                size: mini ? 20 : 24,
              )
            : Icon(icon),
      ),
    );
  }
}