import 'package:flutter/material.dart';

/// Sistema de cores esportivo moderno e atrativo
class SportColors {
  // ===== CORES PRINCIPAIS =====
  
  /// Azul energético principal
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF3385FF);
  
  /// Laranja motivacional
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryDark = Color(0xFFE5522A);
  static const Color secondaryLight = Color(0xFFFF8A5B);
  
  /// Cor de destaque/accent
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentDark = Color(0xFF00B894);
  static const Color accentLight = Color(0xFF1DDBB7);

  // ===== GRADIENTES ESPORTIVOS =====
  
  /// Gradiente principal (azul energético)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente motivacional (laranja/vermelho)
  static const LinearGradient motivationalGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF3838)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente de sucesso (verde/azul)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente premium (roxo/rosa)
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente dark mode
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE DIFICULDADE =====
  
  /// Verde energético para iniciante
  static const Color beginnerColor = Color(0xFF10B981);
  static const LinearGradient beginnerGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Laranja motivacional para intermediário
  static const Color intermediateColor = Color(0xFFFF8F00);
  static const LinearGradient intermediateGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Vermelho intenso para avançado
  static const Color advancedColor = Color(0xFFE53E3E);
  static const LinearGradient advancedGradient = LinearGradient(
    colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES NEUTRAS ESPORTIVAS =====
  
  /// Branco puro
  static const Color white = Color(0xFFFFFFFF);
  
  /// Cinzas esportivos
  static const Color lightGrey = Color(0xFFF7F8FC);
  static const Color grey100 = Color(0xFFF1F3F4);
  static const Color grey200 = Color(0xFFE8EAED);
  static const Color grey300 = Color(0xFFDADCE0);
  static const Color grey400 = Color(0xFFBDC1C6);
  static const Color grey500 = Color(0xFF9AA0A6);
  static const Color grey600 = Color(0xFF80868B);
  static const Color grey700 = Color(0xFF5F6368);
  static const Color grey800 = Color(0xFF3C4043);
  static const Color grey900 = Color(0xFF202124);
  
  /// Pretos esportivos
  static const Color darkBlue = Color(0xFF1A1A2E);
  static const Color darkPurple = Color(0xFF16213E);
  static const Color almostBlack = Color(0xFF0F0F23);

  // ===== CORES DE STATUS =====
  
  /// Sucesso/Concluído
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  
  /// Aviso/Atenção
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  
  /// Erro/Falha
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  
  /// Informação
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // ===== CORES DE TIPOS DE TREINO =====
  
  /// Musculação
  static const Color musculationColor = Color(0xFF6366F1);
  static const LinearGradient musculationGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Cardio
  static const Color cardioColor = Color(0xFFEF4444);
  static const LinearGradient cardioGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Funcional
  static const Color functionalColor = Color(0xFF10B981);
  static const LinearGradient functionalGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Yoga/Pilates
  static const Color yogaColor = Color(0xFF8B5CF6);
  static const LinearGradient yogaGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== HELPERS =====
  
  /// Obter cor por dificuldade
  static Color getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante':
        return beginnerColor;
      case 'intermediario':
        return intermediateColor;
      case 'avancado':
        return advancedColor;
      default:
        return grey500;
    }
  }
  
  /// Obter gradiente por dificuldade
  static LinearGradient getDifficultyGradient(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante':
        return beginnerGradient;
      case 'intermediario':
        return intermediateGradient;
      case 'avancado':
        return advancedGradient;
      default:
        return primaryGradient;
    }
  }
  
  /// Obter cor por tipo de treino
  static Color getWorkoutTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'musculação':
      case 'musculacao':
        return musculationColor;
      case 'cardio':
      case 'cardiovascular':
        return cardioColor;
      case 'funcional':
        return functionalColor;
      case 'yoga':
      case 'pilates':
        return yogaColor;
      default:
        return primary;
    }
  }
  
  /// Obter gradiente por tipo de treino
  static LinearGradient getWorkoutTypeGradient(String? type) {
    switch (type?.toLowerCase()) {
      case 'musculação':
      case 'musculacao':
        return musculationGradient;
      case 'cardio':
      case 'cardiovascular':
        return cardioGradient;
      case 'funcional':
        return functionalGradient;
      case 'yoga':
      case 'pilates':
        return yogaGradient;
      default:
        return primaryGradient;
    }
  }
}

/// Tema esportivo do aplicativo
class SportTheme {
  /// Tema claro esportivo
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de cores
      colorScheme: const ColorScheme.light(
        primary: SportColors.primary,
        onPrimary: SportColors.white,
        secondary: SportColors.secondary,
        onSecondary: SportColors.white,
        tertiary: SportColors.accent,
        onTertiary: SportColors.white,
        surface: SportColors.white,
        onSurface: SportColors.grey900,
        background: SportColors.lightGrey,
        onBackground: SportColors.grey900,
        error: SportColors.error,
        onError: SportColors.white,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: SportColors.white,
        foregroundColor: SportColors.grey900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: SportColors.grey900,
        ),
      ),
      
      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SportColors.primary,
          foregroundColor: SportColors.white,
          elevation: 2,
          shadowColor: SportColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Cards - CORRIGIDO: CardTheme -> CardThemeData
      cardTheme: CardThemeData(
        color: SportColors.white,
        elevation: 2,
        shadowColor: SportColors.grey900.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SportColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SportColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SportColors.primary,
        foregroundColor: SportColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SportColors.white,
        selectedItemColor: SportColors.primary,
        unselectedItemColor: SportColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  /// Tema escuro esportivo
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Esquema de cores dark
      colorScheme: const ColorScheme.dark(
        primary: SportColors.primaryLight,
        onPrimary: SportColors.darkBlue,
        secondary: SportColors.secondaryLight,
        onSecondary: SportColors.darkBlue,
        tertiary: SportColors.accentLight,
        onTertiary: SportColors.darkBlue,
        surface: SportColors.darkBlue,
        onSurface: SportColors.white,
        background: SportColors.almostBlack,
        onBackground: SportColors.white,
        error: SportColors.error,
        onError: SportColors.white,
      ),
      
      // AppBar dark
      appBarTheme: const AppBarTheme(
        backgroundColor: SportColors.darkBlue,
        foregroundColor: SportColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      
      // Cards dark - CORRIGIDO: CardTheme -> CardThemeData
      cardTheme: CardThemeData(
        color: SportColors.darkBlue,
        elevation: 4,
        shadowColor: SportColors.almostBlack.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Extensões para widgets com gradientes
extension SportGradients on Widget {
  /// Aplicar gradiente de fundo
  Widget withGradient(LinearGradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: this,
    );
  }
  
  /// Aplicar gradiente com bordas arredondadas
  Widget withRoundedGradient(LinearGradient gradient, {double radius = 12}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: this,
    );
  }
}

/// Widgets customizados com tema esportivo
class SportWidgets {
  /// Botão com gradiente
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    LinearGradient? gradient,
    double? width,
    double height = 56,
    double borderRadius = 12,
    TextStyle? textStyle,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? SportColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? SportColors.primary).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: SportColors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: textStyle ?? const TextStyle(
                    color: SportColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Card com gradiente
  static Widget gradientCard({
    required Widget child,
    LinearGradient? gradient,
    double borderRadius = 16,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: gradient ?? SportColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? SportColors.primary).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
  
  /// Badge de dificuldade esportivo
  static Widget difficultyBadge({
    required String difficulty,
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    final color = SportColors.getDifficultyColor(difficulty);
    final gradient = SportColors.getDifficultyGradient(difficulty);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          color: SportColors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}