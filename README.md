# Teste Fill Data - n8n POC

Repositório para POC de extração de agendamentos usando n8n com Docker.

## Descrição

Este projeto configura um ambiente local do n8n com SQLite para automatizar a extração e processamento de dados de agendamentos.

## Pré-requisitos

- Docker e Docker Compose instalados
- OpenAI API Key (opcional, para funcionalidades de IA)

## Setup Inicial

1. **Clone o repositório**
   ```bash
   git clone <seu-repositorio>
   cd teste_fill_data
   ```

2. **Configure as variáveis de ambiente**
   ```bash
   cp env.example .env
   # Edite o arquivo .env com suas configurações
   ```

3. **Inicie os containers**
   ```bash
   docker-compose up -d
   ```

4. **Acesse o n8n**
   - URL: http://localhost:5678
   - Usuário: admin
   - Senha: admin123

## Estrutura do Projeto

```
teste_fill_data/
├── .env                 # Variáveis de ambiente (criar a partir do env.example)
├── .gitignore          # Arquivos ignorados pelo git
├── README.md           # Este arquivo
├── docker-compose.yml  # Configuração dos containers
├── init-db.sql         # Script de inicialização do banco
├── env.example         # Template das variáveis de ambiente
└── data/               # Dados persistentes (criado automaticamente)
    ├── agendamentos.db # Banco SQLite
    └── .n8n/           # Dados do n8n
```

## Banco de Dados

A tabela `agendamentos` possui os seguintes campos:
- `id`: Identificador único (auto-incremento)
- `nome`: Nome do cliente
- `telefone`: Telefone do cliente
- `data`: Data do agendamento
- `horario`: Horário do agendamento
- `observacoes`: Observações adicionais
- `created_at`: Data/hora de criação do registro

## Comandos Úteis

```bash
# Iniciar os serviços
docker-compose up -d

# Parar os serviços
docker-compose down

# Ver logs
docker-compose logs -f n8n

# Acessar o banco SQLite
docker exec -it sqlite-init sqlite3 /data/agendamentos.db
```

## Próximos Passos

1. Acesse http://localhost:5678
2. Configure seu workflow visual no n8n
3. Use os nós SQLite para conectar ao banco
4. Configure webhooks ou triggers para automatizar a extração

## Contribuição

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request. 