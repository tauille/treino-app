import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? elevation;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.elevation,
    this.width,
    this.height,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = _buildCardContent();

    // Se tem onTap, envolver com GestureDetector ou InkWell
    if (onTap != null) {
      cardContent = _buildTappableCard(cardContent);
    }

    return cardContent;
  }

  Widget _buildCardContent() {
    // Se há gradient, usar Container personalizado
    if (gradient != null) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          boxShadow: boxShadow ?? _defaultShadow,
          border: _getBorder(),
        ),
        child: child,
      );
    }

    // Caso contrário, usar Card padrão ou Container
    if (elevation != null) {
      return Card(
        margin: margin,
        color: _getBackgroundColor(),
        elevation: elevation!,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          side: _getBorderSide(),
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: boxShadow ?? _defaultShadow,
        border: _getBorder(),
      ),
      child: child,
    );
  }

  Widget _buildTappableCard(Widget cardContent) {
    if (borderRadius != null || gradient != null) {
      // Usar GestureDetector para cards com border radius customizado
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    } else {
      // Usar InkWell para ripple effect
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: cardContent,
      );
    }
  }

  Color _getBackgroundColor() {
    if (isSelected && selectedColor != null) {
      return selectedColor!;
    }
    
    if (isSelected) {
      return const Color(0xFF667eea).withOpacity(0.1);
    }
    
    return color ?? Colors.white;
  }

  Border? _getBorder() {
    if (border != null) return border;
    
    if (isSelected) {
      return Border.all(
        color: selectedColor ?? const Color(0xFF667eea),
        width: 2,
      );
    }
    
    return null;
  }

  BorderSide _getBorderSide() {
    if (isSelected) {
      return BorderSide(
        color: selectedColor ?? const Color(0xFF667eea),
        width: 2,
      );
    }
    
    return BorderSide.none;
  }

  List<BoxShadow> get _defaultShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // ===== FACTORY CONSTRUCTORS =====

  /// Card com gradiente
  factory CustomCard.gradient({
    required Widget child,
    required Gradient gradient,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      gradient: gradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
    );
  }

  /// Card elevado (Material Design)
  factory CustomCard.elevated({
    required Widget child,
    double elevation = 4,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      elevation: elevation,
      color: color,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
    );
  }

  /// Card plano (apenas com sombra sutil)
  factory CustomCard.flat({
    required Widget child,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      color: color,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 0,
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// Card selecionável
  factory CustomCard.selectable({
    required Widget child,
    required bool isSelected,
    Color? selectedColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      isSelected: isSelected,
      selectedColor: selectedColor,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
    );
  }

  /// Card com bordas
  factory CustomCard.outlined({
    required Widget child,
    Color borderColor = Colors.grey,
    double borderWidth = 1,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      border: Border.all(color: borderColor, width: borderWidth),
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      boxShadow: [], // Sem sombra para cards outlined
    );
  }

  /// Card compacto (padding menor)
  factory CustomCard.compact({
    required Widget child,
    Color? color,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      color: color,
      padding: const EdgeInsets.all(12),
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
    );
  }

  /// Card hero (destaque)
  factory CustomCard.hero({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      child: child,
      gradient: LinearGradient(
        colors: [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF667eea).withOpacity(0.3),
          spreadRadius: 0,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}