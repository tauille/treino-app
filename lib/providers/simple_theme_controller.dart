import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌙☀️ CONTROLADOR SIMPLES DE TEMA - Compatível com sua arquitetura
class SimpleThemeController extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  /// Carregar tema salvo
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar tema: $e');
    }
  }
  
  /// Alternar tema
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }
  
  /// Definir tema específico
  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      print('Erro ao definir tema: $e');
    }
  }
}

/// 🔄 BOTÃO SIMPLES PARA ALTERNAR TEMA
class ThemeToggleButton extends StatelessWidget {
  final SimpleThemeController? controller;
  
  const ThemeToggleButton({
    Key? key,
    this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const SizedBox.shrink();
    }
    
    return ListenableBuilder(
      listenable: controller!,
      builder: (context, _) {
        return IconButton(
          onPressed: controller!.toggleTheme,
          icon: Icon(
            controller!.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: controller!.isDarkMode 
              ? 'Modo claro' 
              : 'Modo escuro',
        );
      },
    );
  }
}

/// 🎨 WIDGET PARA CONFIGURAÇÕES DE TEMA
class ThemeSettingsCard extends StatelessWidget {
  final SimpleThemeController controller;
  
  const ThemeSettingsCard({
    Key? key,
    required this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Aparência',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return SwitchListTile(
                  value: controller.isDarkMode,
                  onChanged: controller.setDarkMode,
                  title: Text(
                    controller.isDarkMode ? 'Modo Escuro' : 'Modo Claro',
                  ),
                  subtitle: Text(
                    controller.isDarkMode 
                        ? 'Interface escura ativada'
                        : 'Interface clara ativada',
                  ),
                  secondary: Icon(
                    controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 🏠 EXEMPLO DE COMO USAR NO SEU main.dart
/* 
PASSO 1: Adicionar ao seu main.dart:

import 'simple_theme_controller.dart';

void main() async {
  // ... seu código existente ...
  
  // ADICIONAR ANTES DO runApp:
  final themeController = SimpleThemeController();
  await themeController.loadTheme();
  
  runApp(TreinoAppWithTheme(themeController: themeController));
}

class TreinoAppWithTheme extends StatelessWidget {
  final SimpleThemeController themeController;
  
  const TreinoAppWithTheme({required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Seus providers existentes...
        ChangeNotifierProvider(create: (_) => AuthProviderGoogle()),
        ChangeNotifierProvider(create: (_) => TreinoProvider()),
        Provider<WakelockService>(create: (_) => WakelockService()),
        
        // ADICIONAR:
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: Consumer<SimpleThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Treino App',
            debugShowCheckedModeBanner: false,
            
            // USAR OS DOIS TEMAS:
            theme: SportTheme.lightTheme,
            darkTheme: SportTheme.darkTheme,
            themeMode: themeController.themeMode,
            
            // ... resto do seu código existente ...
          );
        },
      ),
    );
  }
}

PASSO 2: Usar em qualquer tela:

// No AppBar:
actions: [
  ThemeToggleButton(
    controller: Provider.of<SimpleThemeController>(context, listen: false),
  ),
],

// Na tela de configurações:
ThemeSettingsCard(
  controller: Provider.of<SimpleThemeController>(context, listen: false),
),

// Para verificar se está escuro:
final isDark = Theme.of(context).brightness == Brightness.dark;

// Usar no SportWidgets:
SportWidgets.userAvatar(
  initials: 'AM', // Agora tem cor única!
  size: 56,
)
*/