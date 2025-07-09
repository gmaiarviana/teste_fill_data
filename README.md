# Auto Copilot Experiment

## 🎯 Contexto e Motivação

Experimento para criar um sistema de **extração automática de dados** que evolui e aprende, usando **n8n + OpenAI + PostgreSQL**. O objetivo é construir um "copiloto" que:

- **Recebe textos não estruturados** (emails, mensagens, formulários)
- **Extrai dados estruturados** automaticamente
- **Aprende com feedback** e melhora a precisão ao longo do tempo
- **Se adapta a diferentes domínios** e necessidades

## 🏗️ Visão Geral da Arquitetura

```
[Input] → [n8n Orchestration] → [OpenAI Processing] → [PostgreSQL Storage] → [Learning Loop]
```

**Stack Tecnológica:**
- **n8n**: Orquestração de workflows (localhost:5678)
- **PostgreSQL**: Banco de dados da aplicação (localhost:5433)
- **PostgREST**: API REST automática (localhost:3000)
- **OpenAI GPT-4**: Processamento de linguagem natural
- **Docker**: Containerização completa

## 📊 Estrutura de Dados

```sql
-- Tabela principal: interações processadas
CREATE TABLE interactions (
    id SERIAL PRIMARY KEY,
    text_input TEXT NOT NULL,           -- Texto original
    processed_data JSONB,               -- Dados extraídos (JSON)
    status VARCHAR(50),                 -- 'processed', 'validating', 'completed'
    confidence_score DECIMAL(3,2),      -- Confiança na extração (0-1)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Preferências do usuário (Fase 2+)
CREATE TABLE user_preferences (
    id SERIAL PRIMARY KEY,
    field_name VARCHAR(100),            -- Nome do campo
    mapping_rule TEXT,                  -- Regra de mapeamento
    context TEXT,                       -- Contexto específico
    created_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de aprendizado (Fase 3)
CREATE TABLE learning_history (
    id SERIAL PRIMARY KEY,
    pattern TEXT,                       -- Padrão identificado
    correction TEXT,                    -- Correção aplicada
    frequency INTEGER DEFAULT 1,       -- Frequência do padrão
    last_seen TIMESTAMP DEFAULT NOW()
);
```

## 🚀 Implementação por Fases

### ✅ Fase 1: Automação Básica (IMPLEMENTADA)

**Objetivo**: Extração básica de campos pré-definidos

**Workflow n8n atual:**
```
[Webhook/Manual] → [Code] → [OpenAI] → [Code1] → [HTTP Request] → [Response]
```

**Funcionalidades:**
- ✅ Recebe texto via webhook (`/fase1`) ou interface manual
- ✅ Extrai campos fixos: nome, idade, profissão
- ✅ Salva no PostgreSQL via PostgREST
- ✅ Retorna confirmação de sucesso
- ✅ Visualização de dados via workflow separado

**Exemplo:**
```json
// Input
{"text": "João Silva, 30 anos, desenvolvedor Python"}

// Output salvo
{
  "text_input": "João Silva, 30 anos, desenvolvedor Python",
  "processed_data": "{\"nome\": \"João Silva\", \"idade\": 30, \"profissao\": \"desenvolvedor Python\"}",
  "status": "processed",
  "confidence_score": 0.8
}
```

### 🔄 Fase 2: Campos Dinâmicos + Reasoning Loop (PLANEJADA)

**Objetivo**: Sistema inteligente que se auto-valida e pede ajuda quando necessário

**Fluxo proposto:**
```
[Receptor] → [Interpretador] → [Salvar no Banco] → [Reasoning Loop] → [Fim/Validação]
```

**Funcionalidades planejadas:**
- 🎯 **Campos configuráveis**: Usuário define quais campos extrair
- 🤖 **Auto-validação**: Sistema avalia a qualidade da própria extração
- 🔄 **Reasoning loop**: 
  - Se confiança > 80% → marca como "completed"
  - Se confiança < 80% → marca como "validating" e solicita feedback humano
- 📊 **Adaptação**: Ajusta comportamento baseado em dados ambíguos
- 🎛️ **API dinâmica**: `{"text": "...", "fields": ["campo1", "campo2"]}`

**Payload expandido:**
```json
{
  "text": "Maria Santos trabalha há 5 anos como gerente de produto na empresa X",
  "fields": ["nome", "cargo", "experiencia_anos", "empresa"],
  "confidence_threshold": 0.85
}
```

### 🧠 Fase 3: Sistema de Aprendizado (VISÃO FUTURA)

**Objetivo**: Memória persistente que melhora continuamente

**Funcionalidades visionadas:**
- 📚 **Memória de contexto**: Lembra padrões e preferências anteriores
- 🔄 **Feedback loop**: Aprende com correções manuais
- 🎯 **Personalização**: Adapta-se ao estilo e domínio específico do usuário
- 📈 **Melhoria contínua**: Aumenta precisão ao longo do tempo
- 🗂️ **Histórico inteligente**: Usa interações passadas como contexto

**Exemplo de evolução:**
```
Interação 1: "João Silva, eng. software" → aprende que "eng." = "engenheiro"
Interação 50: "Maria Santos, eng. civil" → automaticamente entende o padrão
```

## ⚡ Uso Atual (Fase 1)

### 🖥️ Interface de Desenvolvimento:
```json
// Manual Trigger no n8n:
{
  "body": {
    "text": "Ana Costa, 28 anos, designer UX"
  }
}
```

### 🌐 API de Produção:
```powershell
# Processar texto
Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase1" -Method POST -ContentType "application/json" -Body '{"text": "Pedro Santos, 32 anos, arquiteto de software"}'

# Ver dados salvos
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET

# Limpar banco para testes
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method DELETE
```

### 📊 Visualização:
- **Workflow "Database Viewer"**: Consulta visual via n8n
- **API direta**: PostgREST em `localhost:3000`
- **Logs**: `docker-compose logs -f n8n`

## 🔧 Configuração e Execução

### Arquivo `.env` essencial:
```bash
# OpenAI (obrigatório)
OPENAI_API_KEY=sua-chave-aqui

# Segurança n8n
N8N_ENCRYPTION_KEY=chave-unica-gerada-32-chars
N8N_PASSWORD=admin123

# Bancos de dados
N8N_DB_PASSWORD=n8n_secure_password_2024
APP_DB_PASSWORD=app_secure_password_2024
```

### Comandos principais:
```bash
# Iniciar ambiente completo
docker-compose up -d

# Status dos serviços
docker-compose ps

# Logs em tempo real
docker-compose logs -f
```

## 🎯 Métricas de Sucesso por Fase

### Fase 1 (Atual):
- ✅ Taxa de extração correta dos campos
- ✅ Tempo de processamento < 3s
- ✅ Zero falhas de infraestrutura

### Fase 2 (Próxima):
- 🎯 Taxa de auto-validação > 80%
- 🎯 Redução de intervenção manual em 60%
- 🎯 Suporte a campos dinâmicos

### Fase 3 (Futuro):
- 🔮 Melhoria contínua de precisão
- 🔮 Adaptação automática a novos domínios
- 🔮 Redução de intervenção manual em 90%

## 📁 Onde Encontrar os Dados

**Configurações do n8n:**
- Volume: `n8n_data`
- Banco: `n8n_postgres` (porta 5432)
- Workflows salvos automaticamente

**Dados da aplicação:**
- Banco: `app_postgres` (porta 5433)
- API: PostgREST (porta 3000)
- Dados persistentes via volumes Docker

## 🐛 Debug e Troubleshooting

```bash
# Health checks
curl http://localhost:5678/healthz    # n8n
curl http://localhost:3000/           # PostgREST

# Verificar bancos
docker exec app_postgres pg_isready -U app_user
docker exec n8n_postgres pg_isready -U n8n

# Logs específicos
docker-compose logs n8n           # Workflows
docker-compose logs app_postgres  # Banco dados
docker-compose logs postgrest     # API REST
```

## 🗺️ Roadmap de Desenvolvimento

### Próximos passos imediatos (Fase 2):
1. **Implementar campos dinâmicos** no payload de entrada
2. **Adicionar reasoning loop** com OpenAI para auto-validação
3. **Criar sistema de confiança** baseado em scoring
4. **Implementar queue de validação** para casos ambíguos

### Visão de longo prazo (Fase 3):
1. **Sistema de preferências** persistente por usuário
2. **Aprendizado de padrões** baseado em histórico
3. **Contexto inteligente** usando interações anteriores
4. **API de feedback** para correções e melhorias

---

**Para Claude**: Este é um experimento de IA evolutiva. A Fase 1 funciona perfeitamente. Use os comandos PowerShell acima para interagir com o sistema atual. O objetivo final é criar um sistema que aprende e melhora sozinho.