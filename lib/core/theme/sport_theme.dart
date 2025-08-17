import 'package:flutter/material.dart';

/// 🧡 SISTEMA DE CORES PADRONIZADO - Laranja Principal + Verde para Ícones
class SportColors {
  // ===== CORES PRINCIPAIS PADRONIZADAS =====

  /// 🧡 LARANJA PADRÃO (do botão "Criar Treino")
  static const Color primary = Color(0xFFFF8C42);          // Laranja principal das imagens
  static const Color primaryDark = Color(0xFFE67300);      // Laranja mais escuro
  static const Color primaryLight = Color(0xFFFFB366);     // Laranja mais claro

  /// 🔥 ACCENT - Cor de destaque (mesmo que primary para manter consistência)
  static const Color accent = Color(0xFFFF8C42);           // Accent igual ao primary

  /// 🟢 VERDE PARA ÍCONES (padronizado)
  static const Color iconGreen = Color(0xFF22C55E);        // Verde para ícones
  static const Color iconGreenLight = Color(0xFF4ADE80);   // Verde claro
  static const Color iconGreenDark = Color(0xFF16A34A);    // Verde escuro

  /// Cores secundárias padronizadas
  static const Color secondary = Color(0xFFFF6B6B);        // Vermelho/rosa das imagens
  static const Color tertiary = Color(0xFF6B7280);         // Cinza azulado das imagens

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

  // ===== CORES DE FUNDO PRETO PURO =====

  static const Color background = Color(0xFF000000);           // Preto puro principal
  static const Color backgroundCard = Color(0xFF1A1A1A);       // Cards escuros
  static const Color dashboardCard = Color(0xFF1A1A1A);        // Alias para backgroundCard
  static const Color backgroundLight = Color(0xFF262626);      // Elementos mais claros
  static const Color backgroundDark = Color(0xFF0D0D0D);       // Mais escuro que o principal

  // ===== GRADIENTES PADRONIZADOS =====

  /// Gradiente principal laranja (padrão do app)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFB366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente secundário (vermelho/rosa)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente verde para ícones/sucesso
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de sucesso
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente vermelho/rosa para ações secundárias
  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)],
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
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente motivacional (roxo vibrante)
  static const LinearGradient motivationalGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE TEXTO PARA TEMA ESCURO =====

  static const Color textPrimary = Color(0xFFFFFFFF);          // Texto principal branco
  static const Color textSecondary = Color(0xFFE5E7EB);        // Texto secundário cinza bem claro
  static const Color textTertiary = Color(0xFF9CA3AF);         // Texto terciário cinza médio
  static const Color textMuted = Color(0xFF6B7280);            // Texto desabilitado cinza escuro

  // ===== CORES DE DIFICULDADE PADRONIZADAS =====

  /// Verde para iniciante
  static const Color beginnerColor = Color(0xFF22C55E);
  static const LinearGradient beginnerGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
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
  static const Color advancedColor = Color(0xFFFF6B6B);
  static const LinearGradient advancedGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE TIPOS DE TREINO PADRONIZADAS =====

  /// Musculação - Verde (ícones)
  static const Color musculationColor = Color(0xFF22C55E);
  static const LinearGradient musculationGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cardio - Vermelho/Rosa
  static const Color cardioColor = Color(0xFFFF6B6B);
  static const LinearGradient cardioGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Funcional - Azul
  static const Color functionalColor = Color(0xFF3B82F6);
  static const LinearGradient functionalGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Yoga/Pilates - Roxo
  static const Color yogaColor = Color(0xFF8B5CF6);
  static const LinearGradient yogaGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE STATUS PADRONIZADAS =====

  static const Color success = Color(0xFF22C55E);     // Verde padronizado
  static const Color warning = Color(0xFFFF8C42);     // Laranja padrão
  static const Color error = Color(0xFFFF6B6B);       // Vermelho padrão
  static const Color info = Color(0xFF3B82F6);        // Azul padrão

  // ===== CORES DE NAVEGAÇÃO =====

  static const Color bottomNavBackground = Color(0xFF1A1A1A);     // Nav bar escura
  static const Color bottomNavSelected = Color(0xFFFF8C42);       // Laranja selecionado
  static const Color bottomNavUnselected = Color(0xFF6B7280);     // Cinza não selecionado

  // ===== CORES EXTRAS =====

  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFF374151);                  // Bordas
  static const Color divider = Color(0xFF1F2937);                 // Divisores
  static const Color overlay = Color(0xFF000000);                 // Overlay modal

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

  // ===== CORES PARA AÇÕES RÁPIDAS PADRONIZADAS =====
  
  static const Color actionPrimary = Color(0xFFFF8C42);    // Criar treino
  static const Color actionSecondary = Color(0xFFFF6B6B);  // Biblioteca  
  static const Color actionTertiary = Color(0xFF6B7280);   // Meus treinos
  static const Color actionQuaternary = Color(0xFF22C55E); // Verde para ações positivas

  // ===== GRADIENTES PARA AÇÕES RÁPIDAS =====
  
  static const LinearGradient actionPrimaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFB366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionSecondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionTertiaryGradient = LinearGradient(
    colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
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
            color: Colors.black.withOpacity(0.2),
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
            color ?? SportColors.primary,
            (color ?? SportColors.primary).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (color ?? SportColors.primary).withOpacity(0.3),
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
        color: backgroundColor ?? (color ?? SportColors.primary).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? SportColors.primary).withOpacity(0.4),
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
          avatarColor = SportColors.primary;
          break;
        case 1:
          avatarColor = SportColors.iconGreen;
          break;
        case 2:
          avatarColor = SportColors.secondary;
          break;
        case 3:
          avatarColor = SportColors.functionalColor;
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
        gradient: SportColors.primaryGradient,
        icon: icon,
        height: 56,
        borderRadius: 16,
      ),
    );
  }
}

/// 🖤 TEMA ESCURO PRETO PURO COM CORES PADRONIZADAS
class SportTheme {
  /// Tema padrão (sempre escuro)
  static ThemeData get theme => darkTheme;

  /// 🌙 Tema escuro (principal)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SportColors.background,

      colorScheme: const ColorScheme.dark(
        primary: SportColors.primary,                    // Laranja padrão
        onPrimary: Colors.white,
        secondary: SportColors.iconGreen,                // Verde para ícones
        onSecondary: Colors.white,
        tertiary: SportColors.secondary,                 // Vermelho/rosa
        onTertiary: Colors.white,
        surface: SportColors.backgroundCard,             // Cards escuros
        onSurface: SportColors.textPrimary,              // Texto branco
        background: SportColors.background,              // Preto puro
        onBackground: SportColors.textPrimary,           // Texto branco
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
        color: SportColors.backgroundCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: SportColors.border.withOpacity(0.2),
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
        backgroundColor: SportColors.backgroundCard,
        contentTextStyle: const TextStyle(
          color: SportColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// ☀️ Tema claro (para compatibilidade futura)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: SportColors.primary,                    // Laranja padrão
        onPrimary: Colors.white,
        secondary: SportColors.iconGreen,                // Verde para ícones
        onSecondary: Colors.white,
        tertiary: SportColors.secondary,                 // Vermelho/rosa
        onTertiary: Colors.white,
        surface: Color(0xFFFAFAFA),                      // Superfície clara
        onSurface: Color(0xFF1A1A1A),                    // Texto escuro
        background: Colors.white,                        // Fundo branco
        onBackground: Color(0xFF1A1A1A),                 // Texto escuro
        error: SportColors.error,                        // Vermelho padrão
        onError: Colors.white,
        outline: Color(0xFFE0E0E0),                      // Bordas claras
        surfaceVariant: Color(0xFFF5F5F5),               // Variação de superfície
        onSurfaceVariant: Color(0xFF666666),             // Texto secundário
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: Color(0xFFE0E0E0),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
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
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: SportColors.primary,          // Laranja
        unselectedItemColor: Color(0xFF666666),          // Cinza
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