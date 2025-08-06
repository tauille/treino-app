import 'package:flutter/material.dart';

/// 🧡 SISTEMA DE CORES LARANJA - Apenas tons de laranja
class SportColors {
  // ===== CORES PRINCIPAIS LARANJA =====

  /// Laranja principal
  static const Color primary = Color(0xFFEA580C);
  static const Color primaryDark = Color(0xFFDC2626);
  static const Color primaryLight = Color(0xFFF97316);

  /// Laranja secundário
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryDark = Color(0xFFD97706);
  static const Color secondaryLight = Color(0xFFFBBF24);

  /// Laranja accent
  static const Color accent = Color(0xFFFF8800);
  static const Color accentDark = Color(0xFFE67300);
  static const Color accentLight = Color(0xFFFF9F33);

  // ===== GRADIENTES APENAS LARANJA =====

  /// Gradiente principal laranja
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente secundário laranja escuro
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente laranja claro
  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente laranja vibrante
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF8800), Color(0xFFFF9F33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente premium laranja
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFFF8800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente motivacional laranja
  static const LinearGradient motivationalGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de energia laranja-amarelo (MANTIDO PARA COMPATIBILIDADE)
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de sucesso verde (MANTIDO PARA COMPATIBILIDADE)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE DIFICULDADE LARANJA =====

  /// Laranja claro para iniciante
  static const Color beginnerColor = Color(0xFFFBBF24);
  static const LinearGradient beginnerGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Laranja médio para intermediário
  static const Color intermediateColor = Color(0xFFEA580C);
  static const LinearGradient intermediateGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Laranja escuro para avançado
  static const Color advancedColor = Color(0xFFDC2626);
  static const LinearGradient advancedGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES NEUTRAS PARA TEMA ESCURO =====

  static const Color white = Color(0xFFFFFFFF);

  /// 🔥 FUNDOS PRETOS PUROS
  static const Color background = Color(0xFF000000);           // Preto puro principal
  static const Color backgroundLight = Color(0xFF0A0A0A);      // Preto levemente mais claro
  static const Color backgroundDark = Color(0xFF000000);       // Preto puro

  /// Cinzas para tema escuro
  static const Color grey50 = Color(0xFF1A1A1A);     // Cinza muito escuro
  static const Color grey100 = Color(0xFF262626);    // Cinza escuro
  static const Color grey200 = Color(0xFF333333);    // Cinza médio escuro
  static const Color grey300 = Color(0xFF404040);    // Cinza médio
  static const Color grey400 = Color(0xFF666666);    // Cinza claro
  static const Color grey500 = Color(0xFF808080);    // Cinza
  static const Color grey600 = Color(0xFF999999);    // Cinza claro
  static const Color grey700 = Color(0xFFB3B3B3);    // Cinza muito claro
  static const Color grey800 = Color(0xFFCCCCCC);    // Quase branco
  static const Color grey900 = Color(0xFFE6E6E6);    // Quase branco

  static const Color lightGrey = Color(0xFF1A1A1A);

  // ===== TEXTOS PARA TEMA ESCURO =====

  static const Color textPrimary = Color(0xFFFFFFFF);      // Texto principal branco
  static const Color textSecondary = Color(0xFFCCCCCC);    // Texto secundário cinza claro
  static const Color textTertiary = Color(0xFF999999);     // Texto terciário cinza
  static const Color textLight = Color(0xFF666666);        // Texto claro cinza escuro

  // ===== CORES DE STATUS =====

  static const Color success = Color(0xFF22C55E);  // Verde só para sucesso (MANTIDO)
  static const Color successLight = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF15803D);

  static const Color warning = Color(0xFFFBBF24);  // Laranja claro
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);    // Vermelho mais claro para tema escuro
  static const Color errorLight = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6);     // Azul só para info
  static const Color infoLight = Color(0xFF2563EB);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ===== CORES DE TIPOS DE TREINO LARANJA =====

  /// Musculação - laranja escuro
  static const Color musculationColor = Color(0xFFDC2626);
  static const LinearGradient musculationGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cardio - laranja vibrante
  static const Color cardioColor = Color(0xFFEA580C);
  static const LinearGradient cardioGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Funcional - laranja médio
  static const Color functionalColor = Color(0xFFF59E0B);
  static const LinearGradient functionalGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Yoga/Pilates - laranja claro
  static const Color yogaColor = Color(0xFFFBBF24);
  static const LinearGradient yogaGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== HELPERS MANTIDOS =====

  static Color getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante': return beginnerColor;
      case 'intermediario': case 'intermediário': return intermediateColor;
      case 'avancado': case 'avançado': return advancedColor;
      default: return grey500;
    }
  }

  static LinearGradient getDifficultyGradient(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante': return beginnerGradient;
      case 'intermediario': case 'intermediário': return intermediateGradient;
      case 'avancado': case 'avançado': return advancedGradient;
      default: return primaryGradient;
    }
  }

  static Color getWorkoutTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'musculação': case 'musculacao': return musculationColor;
      case 'cardio': case 'cardiovascular': return cardioColor;
      case 'funcional': return functionalColor;
      case 'yoga': case 'pilates': return yogaColor;
      default: return primary;
    }
  }

  static LinearGradient getWorkoutTypeGradient(String? type) {
    switch (type?.toLowerCase()) {
      case 'musculação': case 'musculacao': return musculationGradient;
      case 'cardio': case 'cardiovascular': return cardioGradient;
      case 'funcional': return functionalGradient;
      case 'yoga': case 'pilates': return yogaGradient;
      default: return primaryGradient;
    }
  }

  // ===== MÉTODOS EXTRAS PARA COMPATIBILIDADE =====

  /// Obter cor de sucesso
  static Color getSuccessColor() => success;

  /// Obter cor de erro
  static Color getErrorColor() => error;

  /// Obter cor de warning
  static Color getWarningColor() => warning;

  /// Obter gradiente de energia
  static LinearGradient getEnergyGradient() => energyGradient;

  // ===== CORES ESPECIAIS PARA TEMA ESCURO =====

  static const Color dashboardCard = Color(0xFF1A1A1A);           // Cards pretos
  static const Color dashboardBackground = Color(0xFF000000);     // Fundo preto puro

  static const Color bottomNavBackground = Color(0xFF1A1A1A);     // Nav bar preta
  static const Color bottomNavSelected = Color(0xFFEA580C);       // Laranja selecionado
  static const Color bottomNavUnselected = Color(0xFF999999);     // Cinza não selecionado

  static const Color actionCardPrimary = Color(0xFFEA580C);
  static const Color actionCardSecondary = Color(0xFFF97316);
  static const Color actionCardTertiary = Color(0xFFF59E0B);
  static const Color actionCardQuaternary = Color(0xFFFBBF24);

  // ===== GRADIENTES EXTRAS PARA COMPATIBILIDADE =====

  /// Gradiente para treinos completos
  static const LinearGradient completedGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para elementos ativos
  static const LinearGradient activeGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// WIDGETS APENAS LARANJA (Atualizados para tema escuro)
class SportWidgets {
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
    final isDisabled = onPressed == null;

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
        boxShadow: !isDisabled ? [
          BoxShadow(
            color: (gradient?.colors.first ?? color ?? SportColors.primary).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
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
                  Icon(
                    icon, 
                    color: Colors.white,
                    size: 20
                  ),
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

  static Widget difficultyBadge({
    required String difficulty,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    final color = SportColors.getDifficultyColor(difficulty);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),  // Mais opaco para tema escuro
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),  // Borda mais visível
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
          : const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF262626)],  // Card escuro
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: SportColors.primary.withOpacity(0.1),
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
                  style: const TextStyle(
                    color: Colors.white70,
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

  static Widget statusBadge({
    required String text,
    Color? color,
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (color ?? SportColors.primary).withOpacity(0.2),  // Mais opaco
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? SportColors.primary).withOpacity(0.4),  // Borda mais visível
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

  /// Avatar com tons de laranja
  static Widget userAvatar({
    required String initials,
    double size = 40,
    Color? backgroundColor,
  }) {
    // Usar diferentes tons de laranja baseado na primeira letra
    Color avatarColor;
    if (initials.isNotEmpty) {
      final firstChar = initials[0].toLowerCase();
      final charCode = firstChar.codeUnitAt(0);

      // Diferentes tons de laranja baseado no código do caractere
      switch (charCode % 4) {
        case 0:
          avatarColor = SportColors.primary;      // Laranja principal
          break;
        case 1:
          avatarColor = SportColors.primaryDark;  // Laranja escuro
          break;
        case 2:
          avatarColor = SportColors.secondary;    // Laranja dourado
          break;
        case 3:
          avatarColor = SportColors.accent;       // Laranja vibrante
          break;
        default:
          avatarColor = SportColors.primary;
      }
    } else {
      avatarColor = SportColors.primary;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? avatarColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// WIDGET COMPACTO PARA CRIAR TREINO (substitui o card cinza grande)
  static Widget createWorkoutButton({
    required VoidCallback onPressed,
    String text = 'Criar Novo Treino',
    IconData icon = Icons.add_circle_outline,
    double? width,
  }) {
    return Container(
      width: width,
      child: SportWidgets.gradientButton(
        text: text,
        onPressed: onPressed,
        gradient: SportColors.primaryGradient,
        icon: icon,
        height: 56,
        borderRadius: 16,
      ),
    );
  }
}

/// Mantendo compatibilidade
class ModernSportWidgets {
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

/// 🖤 TEMA ESCURO PRETO PURO + LARANJA
class SportTheme {
  /// ⚠️ TEMA PADRÃO: SEMPRE ESCURO
  static ThemeData get theme => darkTheme;

  /// 🌙 Tema escuro com preto puro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SportColors.background, // Preto puro

      colorScheme: const ColorScheme.dark(
        primary: SportColors.primary,
        onPrimary: Colors.white,
        secondary: SportColors.secondary,
        onSecondary: Colors.white,
        tertiary: SportColors.accent,
        onTertiary: Colors.white,
        surface: Color(0xFF1A1A1A),                    // Superfícies escuras
        onSurface: SportColors.textPrimary,            // Texto branco
        background: SportColors.background,            // Preto puro
        onBackground: SportColors.textPrimary,         // Texto branco
        error: SportColors.error,
        onError: Colors.white,
        outline: SportColors.grey400,
        surfaceVariant: Color(0xFF262626),             // Variação de superfície
        onSurfaceVariant: SportColors.textSecondary,   // Texto secundário
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),            // AppBar escura
        foregroundColor: SportColors.textPrimary,      // Texto branco
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: Color(0xFF333333),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: SportColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SportColors.primary,
          foregroundColor: Colors.white,
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

      cardTheme: CardThemeData(
        color: SportColors.dashboardCard,              // Cards escuros
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: SportColors.grey300.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SportColors.grey50,                 // Input escuro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SportColors.grey300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SportColors.grey300,
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
        labelStyle: TextStyle(
          color: SportColors.textSecondary,
          fontSize: 16,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SportColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
        iconSize: 28,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SportColors.bottomNavBackground,    // Nav escura
        selectedItemColor: SportColors.bottomNavSelected,    // Laranja
        unselectedItemColor: SportColors.bottomNavUnselected, // Cinza
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

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: SportColors.textPrimary,              // Texto branco
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

      dialogTheme: DialogThemeData(
        backgroundColor: SportColors.dashboardCard,      // Dialogs escuros
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: SportColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: SportColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: SportColors.grey100,            // SnackBar escura
        contentTextStyle: const TextStyle(
          color: SportColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// ☀️ Tema claro REMOVIDO - App sempre escuro
  @deprecated
  static ThemeData get lightTheme => darkTheme;
}