# 🔧 Treino App API - Laravel Backend

> API RESTful robusta para gerenciamento de treinos com autenticação Google OAuth e integração móvel via Sanctum.

## 🚀 Features

✅ **Autenticação**
- Google OAuth integration
- Laravel Sanctum tokens
- User registration/login
- Secure logout

✅ **API RESTful**
- Treinos CRUD operations
- Exercícios management
- User profile management
- Pagination & filtering

✅ **Security**
- CORS configured for mobile
- API rate limiting
- Input validation
- SQL injection protection

## 🛠️ Tech Stack

- **Laravel** 10+
- **PHP** 8.1+
- **MySQL** / SQLite
- **Sanctum** - API Authentication
- **CORS** - Cross-origin requests

## 📋 Requisitos

- **PHP:** >= 8.1
- **Composer** 2.0+
- **MySQL** 8.0+ ou **SQLite**
- **Node.js** 16+ (para assets)

## ⚡ Quick Start

### 1. Clone e Setup
```bash
git clone https://github.com/tauille/treino-app-api.git
cd treino-app-api
composer install
cp .env.example .env
php artisan key:generate
```

### 2. Database Setup
```bash
# Configure .env com suas credenciais do banco

# Executar migrations:
php artisan migrate

# Seeders (opcional):
php artisan db:seed
```

### 3. Configurar Google OAuth
No arquivo `.env`:
```env
GOOGLE_CLIENT_ID=seu_client_id_aqui
GOOGLE_CLIENT_SECRET=seu_secret_aqui
```

### 4. Executar Servidor

#### Para Emulador Android:
```bash
php artisan serve
# Será acessível em http://127.0.0.1:8000
```

#### Para Device Real:
```bash
php artisan serve --host=0.0.0.0 --port=8000
# Será acessível em http://SEU_IP:8000
```

## 📁 Estrutura da API

```
app/
├── Http/
│   └── Controllers/
│       ├── AuthController.php      # Autenticação
│       ├── GoogleAuthController.php # Google OAuth
│       ├── TreinoController.php    # CRUD Treinos
│       └── ExercicioController.php # CRUD Exercícios
├── Models/
│   ├── User.php                    # Usuário
│   ├── Treino.php                  # Treino
│   └── Exercicio.php               # Exercício
└── ...

routes/
└── api.php                         # Rotas da API
```

## 🌐 Endpoints

### **Autenticação**
```http
POST   /api/auth/register           # Registro
POST   /api/auth/login              # Login
POST   /api/auth/logout             # Logout
POST   /api/auth/google             # Google OAuth
GET    /api/auth/me                 # User profile
```

### **Treinos**
```http
GET    /api/treinos                 # Listar treinos
POST   /api/treinos                 # Criar treino
GET    /api/treinos/{id}            # Ver treino
PUT    /api/treinos/{id}            # Atualizar treino
DELETE /api/treinos/{id}            # Deletar treino
```

### **Exercícios**
```http
GET    /api/treinos/{id}/exercicios     # Listar exercícios
POST   /api/treinos/{id}/exercicios     # Criar exercício
GET    /api/treinos/{id}/exercicios/{ex} # Ver exercício
PUT    /api/treinos/{id}/exercicios/{ex} # Atualizar exercício
DELETE /api/treinos/{id}/exercicios/{ex} # Deletar exercício
```

### **Utilitários**
```http
GET    /api/status                  # Status da API
GET    /api/health                  # Health check
```

## 📊 Formato de Resposta

Todas as respostas seguem o padrão:

```json
{
    "success": true,
    "data": {
        // dados da resposta
    },
    "message": "Mensagem descritiva"
}
```

### Erro:
```json
{
    "success": false,
    "message": "Mensagem de erro",
    "errors": {
        // detalhes dos erros (opcional)
    }
}
```

## 🔒 Autenticação

### Google OAuth Flow:
1. Frontend faz login com Google
2. Envia `access_token` para `/api/auth/google`
3. API valida token e retorna Sanctum token
4. Frontend usa Bearer token nas próximas requisições

### Headers necessários:
```http
Authorization: Bearer {sanctum_token}
Accept: application/json
Content-Type: application/json
```

## 🗄️ Database Schema

### Users
```sql
- id (bigint, primary)
- name (string)
- email (string, unique)
- google_id (string, nullable)
- is_premium (boolean, default false)
- trial_started_at (timestamp, nullable)
- created_at, updated_at
```

### Treinos
```sql
- id (bigint, primary)
- user_id (foreign key)
- nome_treino (string)
- tipo_treino (string)
- descricao (text, nullable)
- dificuldade (enum: iniciante,intermediario,avancado)
- status (enum: ativo,inativo)
- created_at, updated_at
```

### Exercicios
```sql
- id (bigint, primary)
- treino_id (foreign key)
- nome_exercicio (string)
- descricao (text, nullable)
- grupo_muscular (string, nullable)
- tipo_execucao (enum: repeticao,tempo)
- repeticoes (integer, nullable)
- series (integer, nullable)
- tempo_execucao (integer, nullable)
- tempo_descanso (integer, nullable)
- peso (decimal, nullable)
- ordem (integer, nullable)
- status (enum: ativo,inativo)
- created_at, updated_at
```

## 🔧 Configuração

### CORS
Configurado em `config/cors.php` para permitir requisições do Flutter.

### Rate Limiting
```php
'api' => [
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

### Sanctum
Configurado em `config/sanctum.php` com expiração de tokens personalizável.

## 🧪 Testing

```bash
# Executar testes:
php artisan test

# Com coverage:
php artisan test --coverage
```

## 🚀 Deploy

### Produção:
1. Configure `.env` de produção
2. Execute `composer install --optimize-autoloader --no-dev`
3. Execute `php artisan config:cache`
4. Execute `php artisan route:cache`
5. Configure servidor web (Apache/Nginx)

## 🔗 Frontend Integration

Este backend serve o app Flutter:
- **Repositório:** https://github.com/tauille/treino-app
- **Platform:** Android/iOS
- **Auth:** Google Sign-In + Sanctum

## 🤝 Contribuição

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/novo-endpoint`
3. Commit: `git commit -m 'feat: adicionar endpoint'`
4. Push: `git push origin feature/novo-endpoint`
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob licença MIT.

## 👨‍💻 Desenvolvedor

**Tauille** - [GitHub](https://github.com/tauille)

## 🔗 Links Relacionados

- 📱 **Flutter App:** https://github.com/tauille/treino-app
- 📚 **Laravel Docs:** https://laravel.com/docs
- 🔐 **Sanctum:** https://laravel.com/docs/sanctum