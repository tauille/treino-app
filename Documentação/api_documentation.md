# 📚 API Documentation - Treino App

> Documentação completa da API RESTful do Treino App com exemplos detalhados de uso.

## 🔗 Base URL

```
Development: http://localhost:8000/api
Production: https://your-domain.com/api
```

## 🔐 Autenticação

A API utiliza **Laravel Sanctum** para autenticação. Após o login, inclua o token em todas as requisições:

```http
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

---

## 📋 **ENDPOINTS**

### **🔐 AUTENTICAÇÃO**

#### **POST** `/auth/register`
Registra um novo usuário.

**Request:**
```json
{
    "name": "João Silva",
    "email": "joao@example.com",
    "password": "123456",
    "password_confirmation": "123456"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "Conta criada com sucesso!",
    "data": {
        "user": {
            "id": 1,
            "name": "João Silva",
            "email": "joao@example.com",
            "is_premium": false,
            "created_at": "2025-01-10T10:00:00.000000Z"
        },
        "token": "1|abcdef...",
        "token_type": "Bearer"
    }
}
```

#### **POST** `/auth/login`
Realiza login do usuário.

**Request:**
```json
{
    "email": "joao@example.com",
    "password": "123456"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Bem-vindo de volta, João Silva!",
    "data": {
        "user": {
            "id": 1,
            "name": "João Silva",
            "email": "joao@example.com",
            "is_premium": false,
            "trial_started_at": "2025-01-10T10:00:00.000000Z",
            "created_at": "2025-01-10T10:00:00.000000Z"
        },
        "token": "2|ghijkl...",
        "token_type": "Bearer"
    }
}
```

#### **POST** `/auth/logout`
Faz logout do usuário atual.

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Logout realizado com sucesso"
}
```

#### **POST** `/auth/google`
Login/Registro via Google OAuth.

**Request:**
```json
{
    "access_token": "google_access_token",
    "google_id": "123456789",
    "name": "João Silva",
    "email": "joao@gmail.com",
    "avatar_url": "https://lh3.googleusercontent.com/..."
}
```

**Response (200/201):**
```json
{
    "success": true,
    "message": "Bem-vindo de volta, João Silva!",
    "data": {
        "user": {
            "id": 1,
            "name": "João Silva",
            "email": "joao@gmail.com",
            "is_premium": false,
            "trial_started_at": "2025-01-10T10:00:00.000000Z",
            "created_at": "2025-01-10T10:00:00.000000Z",
            "email_verified_at": "2025-01-10T10:00:00.000000Z"
        },
        "token": "3|mnopqr...",
        "token_type": "Bearer"
    }
}
```

#### **GET** `/auth/me`
Retorna dados do usuário autenticado.

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "name": "João Silva",
            "email": "joao@example.com",
            "is_premium": false,
            "trial_started_at": "2025-01-10T10:00:00.000000Z",
            "created_at": "2025-01-10T10:00:00.000000Z",
            "email_verified_at": "2025-01-10T10:00:00.000000Z"
        },
        "stats": {
            "total_treinos": 5,
            "treinos_ativos": 3,
            "total_exercicios": 25,
            "membro_desde": "há 2 meses"
        }
    }
}
```

---

### **🏋️ TREINOS**

#### **GET** `/treinos`
Lista todos os treinos do usuário autenticado.

**Headers:**
```http
Authorization: Bearer {token}
```

**Query Parameters:**
| Parâmetro | Tipo | Descrição | Exemplo |
|-----------|------|-----------|---------|
| `busca` | string | Busca por nome/descrição | `?busca=cardio` |
| `dificuldade` | string | Filtra por dificuldade | `?dificuldade=intermediario` |
| `tipo_treino` | string | Filtra por tipo | `?tipo_treino=musculacao` |
| `order_by` | string | Campo para ordenação | `?order_by=nome_treino` |
| `order_direction` | string | Direção (asc/desc) | `?order_direction=asc` |
| `per_page` | integer | Itens por página | `?per_page=10` |

**Response (200):**
```json
{
    "success": true,
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "nome_treino": "Treino Push",
                "tipo_treino": "Musculação",
                "descricao": "Treino focado em peito, ombros e tríceps",
                "dificuldade": "intermediario",
                "dificuldade_texto": "Intermediário",
                "cor_dificuldade": "#ffa500",
                "status": "ativo",
                "total_exercicios": 6,
                "duracao_estimada": 4800,
                "duracao_formatada": "1h 20min",
                "grupos_musculares": "Peito, Ombros, Tríceps",
                "created_at": "2025-01-10T10:00:00.000000Z",
                "updated_at": "2025-01-10T10:00:00.000000Z"
            }
        ],
        "total": 1,
        "per_page": 15,
        "last_page": 1
    },
    "message": "Treinos listados com sucesso"
}
```

#### **GET** `/treinos/{id}`
Exibe um treino específico com seus exercícios.

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "nome_treino": "Treino Push",
        "tipo_treino": "Musculação",
        "descricao": "Treino focado em peito, ombros e tríceps",
        "dificuldade": "intermediario",
        "dificuldade_texto": "Intermediário",
        "cor_dificuldade": "#ffa500",
        "status": "ativo",
        "total_exercicios": 2,
        "duracao_estimada": 2400,
        "duracao_formatada": "40min",
        "grupos_musculares": "Peito, Ombros",
        "exercicios": [
            {
                "id": 1,
                "nome_exercicio": "Supino Reto",
                "descricao": "Exercício para desenvolvimento do peitoral",
                "grupo_muscular": "Peito",
                "tipo_execucao": "repeticao",
                "repeticoes": 12,
                "series": 4,
                "tempo_execucao": null,
                "tempo_descanso": 90,
                "peso": 80.0,
                "unidade_peso": "kg",
                "ordem": 1,
                "observacoes": "Manter controle na descida",
                "texto_execucao": "4 séries de 12 repetições",
                "texto_descanso": "1min 30s",
                "tempo_total_estimado": 1200,
                "imagem_url": null
            }
        ],
        "created_at": "2025-01-10T10:00:00.000000Z",
        "updated_at": "2025-01-10T10:00:00.000000Z"
    },
    "message": "Treino encontrado com sucesso"
}
```

#### **POST** `/treinos`
Cria um novo treino.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
    "nome_treino": "Treino Push",
    "tipo_treino": "Musculação",
    "descricao": "Treino focado em peito, ombros e tríceps",
    "dificuldade": "intermediario",
    "status": "ativo"
}
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "nome_treino": "Treino Push",
        "tipo_treino": "Musculação",
        "descricao": "Treino focado em peito, ombros e tríceps",
        "dificuldade": "intermediario",
        "dificuldade_texto": "Intermediário",
        "status": "ativo"
    },
    "message": "Treino criado com sucesso"
}
```

#### **PUT/PATCH** `/treinos/{id}`
Atualiza um treino existente.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
    "nome_treino": "Treino Push Atualizado",
    "dificuldade": "avancado"
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "nome_treino": "Treino Push Atualizado",
        "tipo_treino": "Musculação",
        "descricao": "Treino focado em peito, ombros e tríceps",
        "dificuldade": "avancado",
        "dificuldade_texto": "Avançado",
        "status": "ativo"
    },
    "message": "Treino atualizado com sucesso"
}
```

#### **DELETE** `/treinos/{id}`
Remove um treino (soft delete).

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Treino removido com sucesso"
}
```

#### **GET** `/treinos/dificuldade/{dificuldade}`
Lista treinos por dificuldade.

**Headers:**
```http
Authorization: Bearer {token}
```

**Parâmetros da URL:**
- `{dificuldade}`: `iniciante`, `intermediario`, ou `avancado`

**Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "nome_treino": "Treino Push",
            "tipo_treino": "Musculação",
            "duracao_formatada": "40min",
            "total_exercicios": 6
        }
    ],
    "message": "Treinos de nível intermediario listados com sucesso"
}
```

---

### **💪 EXERCÍCIOS**

#### **GET** `/treinos/{treino}/exercicios`
Lista todos os exercícios de um treino específico.

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "treino": {
            "id": 1,
            "nome_treino": "Treino Push",
            "total_exercicios": 2
        },
        "exercicios": [
            {
                "id": 1,
                "nome_exercicio": "Supino Reto",
                "descricao": "Exercício para desenvolvimento do peitoral",
                "grupo_muscular": "Peito",
                "tipo_execucao": "repeticao",
                "repeticoes": 12,
                "series": 4,
                "tempo_execucao": null,
                "tempo_descanso": 90,
                "peso": 80.0,
                "unidade_peso": "kg",
                "ordem": 1,
                "observacoes": "Manter controle na descida",
                "status": "ativo",
                "texto_execucao": "4 séries de 12 repetições",
                "texto_descanso": "1min 30s",
                "tempo_total_estimado": 1200,
                "imagem_url": null
            }
        ]
    },
    "message": "Exercícios listados com sucesso"
}
```

#### **POST** `/treinos/{treino}/exercicios`
Cria um novo exercício para um treino.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
    "nome_exercicio": "Supino Reto",
    "descricao": "Exercício para desenvolvimento do peitoral",
    "grupo_muscular": "Peito",
    "tipo_execucao": "repeticao",
    "repeticoes": 12,
    "series": 4,
    "tempo_descanso": 90,
    "peso": 80.0,
    "unidade_peso": "kg",
    "ordem": 1,
    "observacoes": "Manter controle na descida",
    "status": "ativo"
}
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "nome_exercicio": "Supino Reto",
        "grupo_muscular": "Peito",
        "tipo_execucao": "repeticao",
        "texto_execucao": "4 séries de 12 repetições",
        "ordem": 1,
        "status": "ativo"
    },
    "message": "Exercício criado com sucesso"
}
```

#### **PUT** `/treinos/{treino}/exercicios/reordenar`
Reordena exercícios de um treino.

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
    "exercicios": [
        {"id": 1, "ordem": 2},
        {"id": 2, "ordem": 1},
        {"id": 3, "ordem": 3}
    ]
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Exercícios reordenados com sucesso"
}
```

---

## ⚠️ **CÓDIGOS DE ERRO**

| Código | Significado | Exemplo |
|--------|-------------|---------|
| **400** | Bad Request | Dados malformados |
| **401** | Unauthorized | Token inválido/expirado |
| **403** | Forbidden | Sem permissão |
| **404** | Not Found | Recurso não encontrado |
| **422** | Validation Error | Dados inválidos |
| **500** | Server Error | Erro interno |

### **Formato de Erro:**
```json
{
    "success": false,
    "message": "Dados inválidos",
    "errors": {
        "email": ["O campo email é obrigatório."],
        "password": ["A senha deve ter pelo menos 6 caracteres."]
    }
}
```

---

## 🚀 **EXEMPLOS DE USO**

### **Fluxo Completo - Criar Treino com Exercícios:**

1. **Login:**
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@example.com","password":"123456"}'
```

2. **Criar Treino:**
```bash
curl -X POST http://localhost:8000/api/treinos \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"nome_treino":"Treino Push","tipo_treino":"Musculação","dificuldade":"intermediario"}'
```

3. **Adicionar Exercício:**
```bash
curl -X POST http://localhost:8000/api/treinos/1/exercicios \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"nome_exercicio":"Supino Reto","grupo_muscular":"Peito","tipo_execucao":"repeticao","repeticoes":12,"series":4}'
```

---

## 📋 **VALIDAÇÕES**

### **Treinos:**
- `nome_treino`: obrigatório, máximo 255 caracteres
- `tipo_treino`: obrigatório, máximo 255 caracteres
- `dificuldade`: opcional, valores: `iniciante`, `intermediario`, `avancado`
- `status`: opcional, valores: `ativo`, `inativo`

### **Exercícios:**
- `nome_exercicio`: obrigatório, máximo 255 caracteres
- `tipo_execucao`: obrigatório, valores: `repeticao`, `tempo`
- `repeticoes`: obrigatório se `tipo_execucao = repeticao`, mínimo 1
- `tempo_execucao`: obrigatório se `tipo_execucao = tempo`, mínimo 1
- `series`: opcional, mínimo 1
- `peso`: opcional, mínimo 0

---

## 🔗 **Links Úteis**

- **Repositório:** https://github.com/tauille/treino-app-api
- **Frontend:** https://github.com/tauille/treino-app
- **Laravel Sanctum:** https://laravel.com/docs/sanctum
- **Postman Collection:** [Baixar aqui](link-para-collection)