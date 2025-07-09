# Auto Copilot Experiment - README

## Arquitetura

### Stack
- **n8n**: Orquestração e workflows (container Docker)
- **PostgreSQL**: Banco de dados (container Docker) 
- **OpenAI API**: Processamento de linguagem natural
- **Docker Compose**: Gerenciamento dos containers

### Estrutura do Banco de Dados

```sql
-- Tabela principal de interações
CREATE TABLE interactions (
    id SERIAL PRIMARY KEY,
    text_input TEXT NOT NULL,
    processed_data JSONB,
    status VARCHAR(50), -- 'processed', 'validating', 'completed'
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Preferências definidas pelo usuário (Fase 2)
CREATE TABLE user_preferences (
    id SERIAL PRIMARY KEY,
    field_name VARCHAR(100),
    mapping_rule TEXT,
    context TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Histórico de aprendizado (Fase 3)
CREATE TABLE learning_history (
    id SERIAL PRIMARY KEY,
    pattern TEXT,
    correction TEXT,
    frequency INTEGER DEFAULT 1,
    last_seen TIMESTAMP DEFAULT NOW()
);
```

## Implementação das Fases

### Fase 1: Automação Básica
**Fluxo n8n:**
1. **Webhook** - recebe texto não estruturado
2. **OpenAI** - extrai campos pré-definidos (nome, idade, profissão)
3. **PostgreSQL** - insere dados processados
4. **Response** - retorna sucesso

**Payload de entrada:**
```json
{
  "text": "João Silva, 30 anos, engenheiro de software, mora em SP"
}
```

### Fase 2: Campos Dinâmicos + Reasoning Loop
**Fluxo n8n:**
1. **Webhook** - recebe texto + campos desejados
2. **OpenAI** - extrai campos dinâmicos
3. **PostgreSQL** - insere dados
4. **OpenAI Reasoning** - avalia coerência do resultado
5. **IF** - se confiança > 80% → fim, senão → validação
6. **HTTP Request** - notifica para validação manual (se necessário)

**Payload de entrada:**
```json
{
  "text": "João Silva, 30 anos, engenheiro de software, mora em SP",
  "fields": ["nome", "idade", "profissao", "cidade"]
}
```

### Fase 3: Aprendizado e Contexto
**Fluxo n8n:**
1. **Webhook** - recebe texto + campos
2. **PostgreSQL** - consulta preferências e histórico
3. **Code Node** - monta prompt com contexto personalizado
4. **OpenAI** - processa com contexto
5. **PostgreSQL** - insere resultado
6. **OpenAI Reasoning** - avalia com histórico
7. **PostgreSQL** - atualiza aprendizado baseado em resultado

## Setup com Docker

### docker-compose.yml
```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n
      - N8N_BASIC_AUTH_ACTIVE=false
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  app_postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=autocopilot
      - POSTGRES_PASSWORD=autocopilot
      - POSTGRES_DB=autocopilot
    volumes:
      - app_postgres_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"

volumes:
  n8n_data:
  postgres_data:
  app_postgres_data:
```

### Comandos para iniciar:
```bash
# Subir containers
docker-compose up -d

# Acessar n8n
http://localhost:5678

# Conectar ao banco da aplicação
docker exec -it <app_postgres_container> psql -U autocopilot -d autocopilot
```

## Configuração do n8n

### Credenciais necessárias:
1. **OpenAI API** - adicionar chave da API
2. **PostgreSQL** - configurar conexão com app_postgres (porta 5433)

### Webhooks para teste:
- **Fase 1**: `http://localhost:5678/webhook/phase1`
- **Fase 2**: `http://localhost:5678/webhook/phase2` 
- **Fase 3**: `http://localhost:5678/webhook/phase3`

## Testes

### Exemplos de textos para testar:
```bash
# Fase 1 - campos fixos
curl -X POST http://localhost:5678/webhook/phase1 \
  -H "Content-Type: application/json" \
  -d '{"text": "Maria Santos, 28 anos, desenvolvedora Python, Rio de Janeiro"}'

# Fase 2 - campos dinâmicos  
curl -X POST http://localhost:5678/webhook/phase2 \
  -H "Content-Type: application/json" \
  -d '{
    "text": "João Silva, 5 anos de experiência, salário 8000 reais",
    "fields": ["nome", "experiencia_anos", "salario"]
  }'
```

## Métricas de Sucesso

### Fase 1:
- Taxa de extração correta dos campos
- Tempo de processamento

### Fase 2:
- Taxa de auto-validação (casos que não precisaram de intervenção humana)
- Precisão do reasoning loop

### Fase 3:
- Redução de casos de validação manual ao longo do tempo
- Melhoria na precisão com base no aprendizado

## Próximos Passos

1. **Setup inicial**: Configurar Docker + n8n + PostgreSQL
2. **Fase 1**: Implementar fluxo básico
3. **Fase 2**: Adicionar reasoning loop
4. **Fase 3**: Implementar sistema de aprendizado