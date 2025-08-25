import 'package:flutter/material.dart';

/// 🎨 SISTEMA DE CORES PADRONIZADO - Baseado na tela de execução perfeita
/// AZUL CLARO/CÉU CORRIGIDO - COPIE ESTE CONTEÚDO PARA lib/core/theme/sport_theme.dart
class SportColors {
  // ===== CORES PRINCIPAIS CORRIGIDAS =====

  /// 🔵 AZUL CLARO/CÉU (headers e botões finais como "FINALIZAR TREINO")
  static const Color primary = Color(0xFF4A90E2);          // Azul claro/céu da tela de execução
  static const Color primaryDark = Color(0xFF2196F3);      // Azul mais escuro
  static const Color primaryLight = Color(0xFF64B5F6);     // Azul mais claro

  /// 🟠 LARANJA (cards de exercício e botões de ação como "PRÓXIMO EXERCÍCIO")
  static const Color secondary = Color(0xFFFF8C42);        // Laranja dos cards de exercício
  static const Color secondaryDark = Color(0xFFE67300);    // Laranja mais escuro
  static const Color secondaryLight = Color(0xFFFFB366);   // Laranja mais claro

  /// 🎯 COR DE DESTAQUE (ações importantes)
  static const Color accent = Color(0xFFFF8C42);           // Igual ao secondary para consistency

  /// 🔘 CINZA (botões secundários como "PRÓXIMO")
  static const Color tertiary = Color(0xFF95A5A6);         // Cinza dos botões secundários
  static const Color tertiaryDark = Color(0xFF7F8C8D);     // Cinza mais escuro
  static const Color tertiaryLight = Color(0xFFBDC3C7);    // Cinza mais claro

  // ===== ESCALA COMPLETA DE CINZAS =====

  static const Color grey50 = Color(0xFFF9FAFB);           // Cinza muito claro
  static const Color grey100 = Color(0xFFF3F4F6);          // Cinza claro
  static const Color grey200 = Color(0xFFE5E7EB);          // Cinza claro médio
  static const Color grey300 = Color(0xFFD1D5DB);          // Cinza médio claro
  static const Color grey400 = Color(0xFF9CA3AF);          // Cinza médio
  static const Color grey500 = Color(0xFF6B7280);          // Cinza médio escuro
  static const Color grey600 = Color(0xFF4B5563);          // Cinza escuro
  static const Color grey700 = Color(0xFF374151);          // Cinza muito escuro
  static const Color grey800 = Color(0xFF1F2937);          // Cinza quase preto
  static const Color grey900 = Color(0xFF111827);          // Cinza quase preto
  static const Color lightGrey = Color(0xFFF3F4F6);        // Alias para grey100

  // ===== CORES DE FUNDO BRANCO LIMPO =====

  static const Color background = Color(0xFFFFFFFF);           // Branco puro principal
  static const Color backgroundCard = Color(0xFFFFFFFF);       // Cards brancos
  static const Color dashboardCard = Color(0xFFFFFFFF);        // Alias para backgroundCard
  static const Color backgroundLight = Color(0xFFF8F9FA);      // Fundo levemente acinzentado
  static const Color backgroundDark = Color(0xFFF1F3F4);       // Mais escuro que o principal (ainda claro)

  // ===== GRADIENTES PADRONIZADOS =====

  /// Gradiente principal azul claro (headers e finalizações)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente secundário laranja (exercícios e ações)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFB366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente cinza (botões secundários)
  static const LinearGradient tertiaryGradient = LinearGradient(
    colors: [Color(0xFF95A5A6), Color(0xFFBDC3C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente verde para sucesso
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente vermelho para alertas
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente premium (dourado)
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente energy (azul vibrante)
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF4A90E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente motivacional (roxo vibrante)
  static const LinearGradient motivationalGradient = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFFBB8FCE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE TEXTO PARA TEMA CLARO =====

  static const Color textPrimary = Color(0xFF2C3E50);          // Texto principal escuro
  static const Color textSecondary = Color(0xFF5D6D7E);        // Texto secundário cinza escuro
  static const Color textTertiary = Color(0xFF85929E);         // Texto terciário cinza médio
  static const Color textMuted = Color(0xFFAEB6BF);            // Texto desabilitado cinza claro

  // ===== CORES DE DIFICULDADE PADRONIZADAS =====

  /// Verde para iniciante
  static const Color beginnerColor = Color(0xFF27AE60);
  static const LinearGradient beginnerGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Laranja para intermediário  
  static const Color intermediateColor = Color(0xFFFF8C42);
  static const LinearGradient intermediateGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFB366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Vermelho para avançado
  static const Color advancedColor = Color(0xFFE74C3C);
  static const LinearGradient advancedGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE TIPOS DE TREINO PADRONIZADAS =====

  /// Musculação - Verde
  static const Color musculationColor = Color(0xFF27AE60);
  static const LinearGradient musculationGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cardio - Vermelho
  static const Color cardioColor = Color(0xFFE74C3C);
  static const LinearGradient cardioGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Funcional - Azul
  static const Color functionalColor = Color(0xFF2196F3);
  static const LinearGradient functionalGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF4A90E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Yoga/Pilates - Roxo
  static const Color yogaColor = Color(0xFF9B59B6);
  static const LinearGradient yogaGradient = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFFBB8FCE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE STATUS PADRONIZADAS =====

  static const Color success = Color(0xFF27AE60);     // Verde padrão
  static const Color warning = Color(0xFFFF8C42);     // Laranja padrão
  static const Color error = Color(0xFFE74C3C);       // Vermelho padrão
  static const Color info = Color(0xFF4A90E2);        // Azul claro padrão

  // ===== CORES DE NAVEGAÇÃO =====

  static const Color bottomNavBackground = Color(0xFFFFFFFF);     // Nav bar branca
  static const Color bottomNavSelected = Color(0xFFFF8C42);       // Laranja selecionado
  static const Color bottomNavUnselected = Color(0xFF85929E);     // Cinza não selecionado

  // ===== CORES EXTRAS =====

  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);                  // Bordas claras
  static const Color divider = Color(0xFFD1D5DB);                 // Divisores
  static const Color overlay = Color(0x80000000);                 // Overlay modal

  // ===== MÉTODOS HELPER =====

  static Color getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante': return beginnerColor;
      case 'intermediario': case 'intermediário': return intermediateColor;
      case 'avancado': case 'avançado': return advancedColor;
      default: return textMuted;
    }
  }

  static LinearGradient getDifficultyGradient(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'iniciante': return beginnerGradient;
      case 'intermediario': case 'intermediário': return intermediateGradient;
      case 'avancado': case 'avançado': return advancedGradient;
      default: return secondaryGradient;
    }
  }

  static Color getWorkoutTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'musculação': case 'musculacao': return musculationColor;
      case 'cardio': case 'cardiovascular': return cardioColor;
      case 'funcional': return functionalColor;
      case 'yoga': case 'pilates': return yogaColor;
      default: return secondary;
    }
  }

  static LinearGradient getWorkoutTypeGradient(String? type) {
    switch (type?.toLowerCase()) {
      case 'musculação': case 'musculacao': return musculationGradient;
      case 'cardio': case 'cardiovascular': return cardioGradient;
      case 'funcional': return functionalGradient;
      case 'yoga': case 'pilates': return yogaGradient;
      default: return secondaryGradient;
    }
  }

  // ===== CORES PARA AÇÕES RÁPIDAS PADRONIZADAS =====
  
  static const Color actionPrimary = Color(0xFFFF8C42);    // Criar treino (laranja)
  static const Color actionSecondary = Color(0xFFE74C3C);  // Biblioteca (vermelho)
  static const Color actionTertiary = Color(0xFF95A5A6);   // Meus treinos (cinza)
  static const Color actionQuaternary = Color(0xFF27AE60); // Verde para ações positivas

  // ===== GRADIENTES PARA AÇÕES RÁPIDAS =====
  
  static const LinearGradient actionPrimaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFB366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionSecondaryGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionTertiaryGradient = LinearGradient(
    colors: [Color(0xFF95A5A6), Color(0xFFBDC3C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 🎨 WIDGETS PADRONIZADOS
class SportWidgets {
  /// Botão com gradiente padronizado
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
          : SportColors.secondaryGradient), // Mudou para secondary (laranja)
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: !isDisabled ? [
          BoxShadow(
            color: (gradient?.colors.first ?? color ?? SportColors.secondary).withOpacity(0.3),
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

  /// Badge de dificuldade padronizado
  static Widget difficultyBadge({
    required String difficulty,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    final color = SportColors.getDifficultyColor(difficulty);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
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

  /// Card com gradiente padronizado
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
              colors: [SportColors.backgroundCard, SportColors.backgroundLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: SportColors.grey300.withOpacity(0.3),
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

  /// Card de ação padronizado
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
            color ?? SportColors.secondary,
            (color ?? SportColors.secondary).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (color ?? SportColors.secondary).withOpacity(0.3),
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

  /// Badge de status padronizado
  static Widget statusBadge({
    required String text,
    Color? color,
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (color ?? SportColors.secondary).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? SportColors.secondary).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? SportColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Avatar padronizado com cores baseadas em iniciais
  static Widget userAvatar({
    required String initials,
    double size = 40,
    Color? backgroundColor,
  }) {
    Color avatarColor;
    if (initials.isNotEmpty) {
      final firstChar = initials[0].toLowerCase();
      final charCode = firstChar.codeUnitAt(0);

      switch (charCode % 4) {
        case 0:
          avatarColor = SportColors.secondary;
          break;
        case 1:
          avatarColor = SportColors.success;
          break;
        case 2:
          avatarColor = SportColors.primary;
          break;
        case 3:
          avatarColor = SportColors.functionalColor;
          break;
        default:
          avatarColor = SportColors.secondary;
      }
    } else {
      avatarColor = SportColors.secondary;
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

  /// Botão compacto para criar treino
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
        gradient: SportColors.secondaryGradient, // Mudou para secondary (laranja)
        icon: icon,
        height: 56,
        borderRadius: 16,
      ),
    );
  }
}

/// 🌞 TEMA CLARO BRANCO LIMPO COM CORES PADRONIZADAS
class SportTheme {
  /// Tema padrão (sempre claro)
  static ThemeData get theme => lightTheme;

  /// ☀️ Tema claro (principal)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SportColors.background,

      colorScheme: const ColorScheme.light(
        primary: SportColors.primary,                    // Azul/turquesa padrão
        onPrimary: Colors.white,
        secondary: SportColors.secondary,                // Laranja para exercícios
        onSecondary: Colors.white,
        tertiary: SportColors.tertiary,                  // Cinza para botões secundários
        onTertiary: Colors.white,
        surface: SportColors.backgroundCard,             // Cards brancos
        onSurface: SportColors.textPrimary,              // Texto escuro
        background: SportColors.background,              // Branco puro
        onBackground: SportColors.textPrimary,           // Texto escuro
        error: SportColors.error,                        // Vermelho padrão
        onError: Colors.white,
        outline: SportColors.border,                     // Bordas
        surfaceVariant: SportColors.backgroundLight,     // Variação de superfície
        onSurfaceVariant: SportColors.textSecondary,     // Texto secundário
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: SportColors.backgroundCard,
        foregroundColor: SportColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: SportColors.border,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: SportColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SportColors.secondary, // Mudou para secondary (laranja)
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
        color: SportColors.backgroundCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: SportColors.border.withOpacity(0.5),
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
        fillColor: SportColors.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SportColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SportColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: SportColors.secondary, // Mudou para secondary (laranja)
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
        backgroundColor: SportColors.secondary, // Mudou para secondary (laranja)
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
        iconSize: 28,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SportColors.bottomNavBackground,
        selectedItemColor: SportColors.bottomNavSelected,      // Laranja
        unselectedItemColor: SportColors.bottomNavUnselected,  // Cinza
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

      dialogTheme: DialogThemeData(
        backgroundColor: SportColors.backgroundCard,
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
        backgroundColor: SportColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 🌙 Tema escuro (para compatibilidade futura)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),

      colorScheme: const ColorScheme.dark(
        primary: SportColors.primary,                    // Azul/turquesa padrão
        onPrimary: Colors.white,
        secondary: SportColors.secondary,                // Laranja para exercícios
        onSecondary: Colors.white,
        tertiary: SportColors.tertiary,                  // Cinza para botões secundários
        onTertiary: Colors.white,
        surface: Color(0xFF2A2A2A),                      // Superfície escura
        onSurface: Colors.white,                         // Texto branco
        background: Color(0xFF1A1A1A),                   // Fundo escuro
        onBackground: Colors.white,                      // Texto branco
        error: SportColors.error,                        // Vermelho padrão
        onError: Colors.white,
        outline: Color(0xFF404040),                      // Bordas escuras
        surfaceVariant: Color(0xFF333333),               // Variação de superfície
        onSurfaceVariant: Color(0xFFCCCCCC),             // Texto secundário
      ),

      // Resto do tema escuro similar ao claro, mas com cores ajustadas
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: Color(0xFF404040),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

/// Mantendo compatibilidade com código antigo
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