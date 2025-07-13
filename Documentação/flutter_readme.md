# 📱 Treino App - Flutter Frontend

> App móvel moderno para gerenciamento de treinos personalizados com autenticação Google e integração com API Laravel.

## 🚀 Features

✅ **Autenticação**
- Google Sign-In integrado
- Sistema de tokens seguro
- Logout completo

✅ **Conectividade**
- Integração com API Laravel
- Device real mode configurado
- Timeouts otimizados (15s)

✅ **Arquitetura**
- Provider pattern para state management
- ApiConfig centralizado
- Estrutura de assets organizada

## 🛠️ Tech Stack

- **Flutter** 3.1.0+
- **Dart** 3.0+
- **Provider** - State management
- **Google Sign In** - Autenticação
- **HTTP** - API calls
- **Secure Storage** - Armazenamento seguro

## 📱 Requisitos

- **Flutter SDK:** >= 3.1.0
- **Dart SDK:** >= 3.0.0
- **Android:** API level 21+ (Android 5.0+)
- **iOS:** 12.0+

## ⚡ Quick Start

### 1. Clone e Setup
```bash
git clone https://github.com/tauille/treino-app.git
cd treino-app
flutter pub get
```

### 2. Assets
Certifique-se de ter a fonte Poppins em `assets/fonts/`:
- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf` 
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

### 3. Configuração API
Em `lib/config/api_config.dart`, ajuste para seu ambiente:

```dart
// Para emulador Android:
static const String _devBaseUrl = 'http://10.0.2.2:8000/api';

// Para device real:
ApiConfig.useDeviceRealMode('SEU_IP_AQUI');
```

### 4. Google Sign-In
Configure o Client ID no Google Cloud Console e ajuste em:
`lib/core/constants/google_config.dart`

### 5. Executar
```bash
# Emulador Android:
flutter run

# Device real:
# 1. Configure seu IP com ApiConfig.useDeviceRealMode()
# 2. Execute Laravel: php artisan serve --host=0.0.0.0
# 3. flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── config/              # Configurações (API, Google)
├── core/
│   ├── constants/       # Constantes globais
│   ├── services/        # Serviços (Auth, API)
│   └── utils/          # Utilitários
├── models/             # Modelos de dados
├── providers/          # State management
├── screens/            # Telas do app
│   ├── auth/          # Autenticação
│   ├── home/          # Página inicial
│   └── onboarding/    # Introdução
└── widgets/           # Componentes reutilizáveis
    └── common/        # Widgets comuns
```

## 🔧 Configuração de Desenvolvimento

### Device Real Mode
Para testar em dispositivo físico:

```dart
// No main.dart:
ApiConfig.useDeviceRealMode('192.168.1.100'); // Seu IP
```

### Debug API
```dart
// Ativar logs detalhados:
ApiConfig.printConfig();
await ApiConfig.testConnection();
```

## 🔗 API Integration

Este app conecta com a API Laravel:
- **Repositório:** https://github.com/tauille/treino-app-api
- **Endpoints:** `/api/auth/google`, `/api/treinos`, etc.
- **Auth:** Bearer tokens via Sanctum

## 🚀 Build para Produção

```bash
# Android APK:
flutter build apk --release

# Android Bundle:
flutter build appbundle --release

# iOS:
flutter build ios --release
```

## 🤝 Contribuição

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'feat: adicionar nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob licença MIT.

## 👨‍💻 Desenvolvedor

**Tauille** - [GitHub](https://github.com/tauille)

## 🔗 Links Relacionados

- 🔧 **API Backend:** https://github.com/tauille/treino-app-api
- 📚 **Documentação Flutter:** https://docs.flutter.dev
- 🔐 **Google Sign-In:** https://pub.dev/packages/google_sign_in