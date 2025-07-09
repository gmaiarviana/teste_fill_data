# 🚀 Setup do Sistema de Automação com n8n

Este documento contém todas as instruções necessárias para configurar e executar o ambiente de desenvolvimento com n8n e PostgreSQL.

## 📋 Pré-requisitos

- Docker Desktop instalado e funcionando
- Docker Compose (v3.8+)
- Git
- Editor de código (VS Code recomendado)

## 🛠️ Configuração Inicial

### 1. Clone o repositório
```bash
git clone <url-do-repositorio>
cd teste_fill_data
```

### 2. Configure as variáveis de ambiente
```bash
# Copie o arquivo de exemplo
cp env.example .env

# Edite o arquivo .env com suas configurações
# ⚠️ IMPORTANTE: Configure sua OPENAI_API_KEY real
```

### 3. Gere uma chave de criptografia segura
```bash
# No Windows PowerShell:
openssl rand -hex 32

# Ou use um gerador online seguro
# Substitua o valor de N8N_ENCRYPTION_KEY no arquivo .env
```

## 🚀 Executando o Ambiente

### Subir todos os serviços
```bash
docker-compose up -d
```

### Verificar status dos containers
```bash
docker-compose ps
```

### Ver logs em tempo real
```bash
# Todos os serviços
docker-compose logs -f

# Apenas n8n
docker-compose logs -f n8n

# Apenas bancos de dados
docker-compose logs -f n8n_postgres app_postgres
```

## 🌐 Acessando os Serviços

### n8n - Interface de Automação
- **URL**: http://localhost:5678
- **Usuário**: admin (configurável no .env)
- **Senha**: admin123 (configurável no .env)

### Banco de Dados n8n (PostgreSQL)
- **Host**: localhost
- **Porta**: 5432
- **Database**: n8n
- **Usuário**: n8n
- **Senha**: n8n_secure_password_2024

### Banco de Dados da Aplicação (PostgreSQL)
- **Host**: localhost
- **Porta**: 5433
- **Database**: app_db
- **Usuário**: app_user
- **Senha**: app_secure_password_2024

### PostgREST - API REST PostgreSQL
- **URL**: http://localhost:3000
- **Documentação automática**: http://localhost:3000/
- **Swagger/OpenAPI**: Detecta automaticamente as tabelas e cria endpoints

**Endpoints principais:**
- `GET /interactions` - Listar interações
- `POST /interactions` - Criar nova interação
- `GET /user_preferences` - Listar preferências
- `GET /learning_history` - Histórico de aprendizado

## 🔧 Comandos Úteis para Desenvolvimento

### Gerenciamento de Containers
```bash
# Parar todos os serviços
docker-compose down

# Parar e remover volumes (⚠️ CUIDADO: perde dados)
docker-compose down -v

# Reiniciar um serviço específico
docker-compose restart n8n

# Reconstruir containers
docker-compose up -d --build
```

### Acesso aos Bancos de Dados

#### Conectar ao banco n8n
```bash
# Via Docker
docker exec -it n8n_postgres psql -U n8n -d n8n

# Via cliente PostgreSQL local
psql -h localhost -p 5432 -U n8n -d n8n
```

#### Conectar ao banco da aplicação
```bash
# Via Docker
docker exec -it app_postgres psql -U app_user -d app_db

# Via cliente PostgreSQL local
psql -h localhost -p 5433 -U app_user -d app_db
```

### Comandos SQL Úteis

#### Verificar tabelas criadas
```sql
-- No banco app_db
\dt

-- Ver estrutura das tabelas
\d interactions
\d user_preferences
\d learning_history
```

#### Inserir dados de teste
```sql
-- Exemplo de inserção na tabela interactions
INSERT INTO interactions (text_input, processed_data, status, confidence_score) 
VALUES ('Teste de entrada', '{"result": "sucesso"}', 'completed', 0.95);

-- Verificar dados inseridos
SELECT * FROM interactions;
```

### Backup e Restore

#### Backup dos bancos
```bash
# Backup do banco n8n
docker exec n8n_postgres pg_dump -U n8n n8n > backup_n8n.sql

# Backup do banco da aplicação
docker exec app_postgres pg_dump -U app_user app_db > backup_app.sql
```

#### Restore dos bancos
```bash
# Restore do banco n8n
docker exec -i n8n_postgres psql -U n8n n8n < backup_n8n.sql

# Restore do banco da aplicação
docker exec -i app_postgres psql -U app_user app_db < backup_app.sql
```

## 🔍 Debug e Troubleshooting

### Verificar logs de erro
```bash
# Logs de erro do n8n
docker-compose logs n8n | grep -i error

# Logs de erro dos bancos
docker-compose logs n8n_postgres | grep -i error
docker-compose logs app_postgres | grep -i error

# Logs de erro do PostgREST
docker-compose logs postgrest | grep -i error
```

### Verificar conectividade entre containers
```bash
# Testar conexão do n8n com o banco
docker exec n8n ping n8n_postgres

# Verificar se os bancos estão respondendo
docker exec n8n_postgres pg_isready -U n8n
docker exec app_postgres pg_isready -U app_user

# Verificar se o PostgREST está respondendo
docker exec postgrest curl -f http://localhost:3000/
```

### Problemas Comuns

#### Porta já em uso
```bash
# Verificar o que está usando a porta
netstat -ano | findstr :5678
netstat -ano | findstr :5432
netstat -ano | findstr :5433
netstat -ano | findstr :3000

# Parar o processo que está usando a porta
taskkill /PID <PID> /F
```

#### Containers não iniciam
```bash
# Verificar se há conflitos de nome
docker ps -a

# Remover containers órfãos
docker container prune

# Limpar volumes não utilizados
docker volume prune
```

#### Problemas de permissão (Linux/Mac)
```bash
# Ajustar permissões dos volumes
sudo chown -R 1000:1000 ./data
```

## 📊 Monitoramento

### Verificar uso de recursos
```bash
# Status dos containers
docker stats

# Uso de disco dos volumes
docker system df
```

### Health Checks
Os containers possuem health checks configurados:
- **n8n**: Verifica se a aplicação responde na porta 5678
- **n8n_postgres**: Verifica se o PostgreSQL está pronto
- **app_postgres**: Verifica se o PostgreSQL está pronto
- **postgrest**: Verifica se a API REST está respondendo

### Testando o PostgREST

#### Teste rápido via PowerShell
```powershell
# Verificar se a API está rodando
Invoke-RestMethod -Uri "http://localhost:3000/" -Method GET

# Listar interações
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET

# Inserir dados de teste
$testData = @{
    text_input = "João Silva, 30 anos, desenvolvedor"
    processed_data = '{"nome": "João Silva", "idade": 30}'
    status = "processed"
    confidence_score = 0.85
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method POST -ContentType "application/json" -Body $testData
```

#### Teste completo via script
```powershell
# Executar script de teste completo
.\test-api.ps1
```

## 🔐 Segurança

### Configurações Recomendadas para Produção

1. **Altere todas as senhas padrão** no arquivo `.env`
2. **Use HTTPS** com certificados SSL válidos
3. **Configure firewall** para restringir acesso às portas
4. **Use secrets do Docker** para senhas sensíveis
5. **Configure backup automático** dos bancos de dados
6. **Monitore logs** regularmente

### Variáveis de Ambiente Críticas

```bash
# Sempre configure estas variáveis em produção:
N8N_ENCRYPTION_KEY=<chave-única-gerada>
OPENAI_API_KEY=<sua-chave-real>
N8N_PASSWORD=<senha-forte>
N8N_DB_PASSWORD=<senha-forte>
APP_DB_PASSWORD=<senha-forte>
POSTGREST_JWT_SECRET=<chave-jwt-única>
```

## 📚 Próximos Passos

1. **Configure sua OPENAI_API_KEY** no arquivo `.env`
2. **Configure o POSTGREST_JWT_SECRET** no arquivo `.env`
3. **Acesse o n8n** em http://localhost:5678
4. **Teste o PostgREST** em http://localhost:3000
5. **Crie seu primeiro workflow** de automação usando HTTP Request ao invés do nó PostgreSQL
4. **Conecte com o banco de dados** da aplicação
5. **Teste as integrações** com OpenAI

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs: `docker-compose logs`
2. Consulte a documentação oficial do n8n
3. Verifique se todas as variáveis de ambiente estão configuradas
4. Teste a conectividade entre os containers

---

**🎉 Parabéns! Seu ambiente está pronto para desenvolvimento!** 