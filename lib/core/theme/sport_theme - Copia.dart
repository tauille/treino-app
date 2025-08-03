import 'package:flutter/material.dart';

/// Sistema de cores moderno e suave - REDESIGN 2024
class SportColors {
  // ===== CORES PRINCIPAIS SUAVES =====
  
  /// Azul suave principal - menos intenso, mais elegante
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  
  /// Verde menta motivacional - suave e fresco
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);
  
  /// Cor de destaque suave
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentDark = Color(0xFF0891B2);
  static const Color accentLight = Color(0xFF22D3EE);

  // ===== GRADIENTES SUAVES =====
  
  /// Gradiente principal suave (azul elegante)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente secundário (verde menta fresco)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente de sucesso suave
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente premium elegante
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de energia (para ações principais)
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// ✅ ADICIONADO: Gradiente motivacional (que estava faltando)
  static const LinearGradient motivationalGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE DIFICULDADE SUAVES =====
  
  /// Verde suave para iniciante
  static const Color beginnerColor = Color(0xFF22C55E);
  static const LinearGradient beginnerGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Laranja suave para intermediário
  static const Color intermediateColor = Color(0xFFF59E0B);
  static const LinearGradient intermediateGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Vermelho suave para avançado
  static const Color advancedColor = Color(0xFFEF4444);
  static const LinearGradient advancedGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES NEUTRAS MODERNAS =====
  
  /// Branco puro
  static const Color white = Color(0xFFFFFFFF);
  
  /// Fundos suaves e modernos
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFFCFCFD);
  static const Color backgroundDark = Color(0xFFF8F9FA);
  
  /// Cinzas suaves e elegantes
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFE5E5E5);
  static const Color grey300 = Color(0xFFD4D4D4);
  static const Color grey400 = Color(0xFFA3A3A3);
  static const Color grey500 = Color(0xFF737373);
  static const Color grey600 = Color(0xFF525252);
  static const Color grey700 = Color(0xFF404040);
  static const Color grey800 = Color(0xFF262626);
  static const Color grey900 = Color(0xFF171717);

  /// ✅ ADICIONADO: lightGrey (que estava faltando)
  static const Color lightGrey = Color(0xFFF5F5F5);

  // ===== TEXTOS COM MELHOR CONTRASTE =====
  
  /// Textos principais
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);

  // ===== CORES DE STATUS SUAVES =====
  
  /// Sucesso suave
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successDark = Color(0xFF059669);
  
  /// Aviso suave
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  
  /// Erro suave
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);
  
  /// Informação suave
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEBF8FF);
  static const Color infoDark = Color(0xFF2563EB);

  // ===== CORES DE TIPOS DE TREINO SUAVES =====
  
  /// Musculação - roxo suave
  static const Color musculationColor = Color(0xFF8B5CF6);
  static const LinearGradient musculationGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Cardio - coral suave
  static const Color cardioColor = Color(0xFFFF6B6B);
  static const LinearGradient cardioGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Funcional - verde azulado
  static const Color functionalColor = Color(0xFF06B6D4);
  static const LinearGradient functionalGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Yoga/Pilates - rosa suave
  static const Color yogaColor = Color(0xFFEC4899);
  static const LinearGradient yogaGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== HELPERS ATUALIZADOS =====
  
  /// Obter cor por dificuldade
  static Color getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante':
        return beginnerColor;
      case 'intermediario':
      case 'intermediário':
        return intermediateColor;
      case 'avancado':
      case 'avançado':
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
      case 'intermediário':
        return intermediateGradient;
      case 'avancado':
      case 'avançado':
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

  // ===== CORES ESPECIAIS PARA O NOVO DESIGN =====
  
  /// Cor para dashboard cards
  static const Color dashboardCard = Color(0xFFFFFFFF);
  static const Color dashboardBackground = Color(0xFFFAFAFA);
  
  /// Cores para bottom navigation
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = Color(0xFF6366F1);
  static const Color bottomNavUnselected = Color(0xFF9CA3AF);
  
  /// Cores para actions cards
  static const Color actionCardPrimary = Color(0xFF6366F1);
  static const Color actionCardSecondary = Color(0xFF10B981);
  static const Color actionCardTertiary = Color(0xFFF59E0B);
  static const Color actionCardQuaternary = Color(0xFFEC4899);
}

/// ✅ ADICIONADO: Classe SportWidgets com todos os métodos que seu código precisa
class SportWidgets {
  /// Botão com gradiente
  static Widget gradientButton({
    required String text,
    required VoidCallback? onPressed,
    LinearGradient? gradient,
    Color? color,
    double? width,
    double height = 50,
    double borderRadius = 16,
    TextStyle? textStyle,
    bool isLoading = false,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? (color != null 
          ? LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : SportColors.primaryGradient),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (color ?? SportColors.primary).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Text(
                    text,
                    style: textStyle ?? const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge de dificuldade
  static Widget difficultyBadge({
    required String difficulty,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    final color = SportColors.getDifficultyColor(difficulty);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// Card com gradiente
  static Widget gradientCard({
    required Widget child,
    LinearGradient? gradient,
    Color? color,
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.all(20),
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? (color != null 
          ? LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : SportColors.primaryGradient),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: (color ?? SportColors.primary).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  /// Card de ação moderno (mantido da versão anterior)
  static Widget actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    LinearGradient? gradient,
    bool isActive = true,
    double? width,
    double height = 120,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [
            color ?? SportColors.primary,
            (color ?? SportColors.primary).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (color ?? SportColors.primary).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Badge moderno de status
  static Widget statusBadge({
    required String text,
    Color? color,
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (color ?? SportColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? SportColors.primary).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? SportColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Widgets customizados modernos (mantido para compatibilidade)
class ModernSportWidgets {
  /// Card de ação moderno
  static Widget actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    LinearGradient? gradient,
    bool isActive = true,
    double? width,
    double height = 120,
  }) {
    return SportWidgets.actionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      color: color,
      gradient: gradient,
      isActive: isActive,
      width: width,
      height: height,
    );
  }
  
  /// Badge moderno de status
  static Widget statusBadge({
    required String text,
    Color? color,
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    return SportWidgets.statusBadge(
      text: text,
      color: color,
      backgroundColor: backgroundColor,
      padding: padding,
    );
  }
}

/// Tema moderno e suave do aplicativo
class SportTheme {
  /// Tema claro moderno
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de cores suaves
      colorScheme: const ColorScheme.light(
        primary: SportColors.primary,
        onPrimary: SportColors.white,
        secondary: SportColors.secondary,
        onSecondary: SportColors.white,
        tertiary: SportColors.accent,
        onTertiary: SportColors.white,
        surface: SportColors.white,
        onSurface: SportColors.textPrimary,
        background: SportColors.background,
        onBackground: SportColors.textPrimary,
        error: SportColors.error,
        onError: SportColors.white,
        outline: SportColors.grey300,
      ),
      
      // AppBar moderna
      appBarTheme: const AppBarTheme(
        backgroundColor: SportColors.white,
        foregroundColor: SportColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: SportColors.grey200,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: SportColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      
      // Botões elevados modernos
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SportColors.primary,
          foregroundColor: SportColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Cards modernos
      cardTheme: CardThemeData(
        color: SportColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: SportColors.grey200.withOpacity(0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      
      // Inputs modernos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SportColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SportColors.grey200,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SportColors.grey200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: SportColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: SportColors.textTertiary,
          fontSize: 16,
        ),
      ),
      
      // FAB moderno
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SportColors.primary,
        foregroundColor: SportColors.white,
        elevation: 4,
        shape: CircleBorder(),
        iconSize: 28,
      ),
      
      // Bottom Navigation moderno
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SportColors.bottomNavBackground,
        selectedItemColor: SportColors.bottomNavSelected,
        unselectedItemColor: SportColors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Texto moderno
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: SportColors.textPrimary,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: SportColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: SportColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: SportColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SportColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SportColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: SportColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: SportColors.textSecondary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: SportColors.textTertiary,
          height: 1.3,
        ),
      ),
    );
  }
  
  /// Tema escuro moderno (para futuro)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: SportColors.primaryLight,
        onPrimary: SportColors.grey900,
        secondary: SportColors.secondaryLight,
        onSecondary: SportColors.grey900,
        tertiary: SportColors.accentLight,
        onTertiary: SportColors.grey900,
        surface: SportColors.grey800,
        onSurface: SportColors.white,
        background: SportColors.grey900,
        onBackground: SportColors.white,
        error: SportColors.error,
        onError: SportColors.white,
      ),
    );
  }
}