# 🚀 Teste da API PostgREST

Este documento contém exemplos práticos de como usar a API REST automática do PostgreSQL através do PostgREST.

## 📋 Informações da API

- **URL Base**: http://localhost:3000
- **Documentação**: http://localhost:3000/ (detecta automaticamente as tabelas)
- **Swagger/OpenAPI**: Disponível automaticamente

## 🗄️ Endpoints Disponíveis

### Tabela: `interactions`
- `GET /interactions` - Listar todos os registros
- `POST /interactions` - Inserir novo registro
- `GET /interactions?id=eq.1` - Buscar por ID específico
- `PATCH /interactions?id=eq.1` - Atualizar registro específico
- `DELETE /interactions?id=eq.1` - Deletar registro específico

### Tabela: `user_preferences`
- `GET /user_preferences` - Listar todas as preferências
- `POST /user_preferences` - Inserir nova preferência
- `GET /user_preferences?field_name=eq.nome` - Buscar por campo específico

### Tabela: `learning_history`
- `GET /learning_history` - Listar histórico de aprendizado
- `POST /learning_history` - Inserir novo registro de aprendizado
- `GET /learning_history?pattern=eq.erro` - Buscar por padrão específico

## 🔧 Exemplos de Uso

### PowerShell - Inserir Dados

```powershell
# Inserir nova interação
$interactionData = @{
    text_input = "João Silva, 30 anos, desenvolvedor"
    processed_data = '{"nome": "João Silva", "idade": 30, "profissao": "desenvolvedor"}'
    status = "processed"
    confidence_score = 0.85
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method POST -ContentType "application/json" -Body $interactionData
```

### PowerShell - Listar Dados

```powershell
# Listar todas as interações
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET

# Buscar por status específico
Invoke-RestMethod -Uri "http://localhost:3000/interactions?status=eq.processed" -Method GET

# Buscar com ordenação
Invoke-RestMethod -Uri "http://localhost:3000/interactions?order=created_at.desc" -Method GET

# Limitar resultados
Invoke-RestMethod -Uri "http://localhost:3000/interactions?limit=5" -Method GET
```

### PowerShell - Atualizar Dados

```powershell
# Atualizar status de uma interação
$updateData = @{
    status = "completed"
    confidence_score = 0.95
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/interactions?id=eq.1" -Method PATCH -ContentType "application/json" -Body $updateData
```

### PowerShell - Deletar Dados

```powershell
# Deletar registro específico
Invoke-RestMethod -Uri "http://localhost:3000/interactions?id=eq.1" -Method DELETE
```

## 🔍 Filtros e Consultas Avançadas

### Operadores de Comparação
- `eq` - Igual
- `neq` - Diferente
- `gt` - Maior que
- `gte` - Maior ou igual
- `lt` - Menor que
- `lte` - Menor ou igual
- `like` - Contém (case-insensitive)
- `ilike` - Contém (case-insensitive)
- `in` - Está em lista

### Exemplos de Filtros

```powershell
# Buscar interações com confiança alta
Invoke-RestMethod -Uri "http://localhost:3000/interactions?confidence_score=gte.0.8" -Method GET

# Buscar por texto que contenha "João"
Invoke-RestMethod -Uri "http://localhost:3000/interactions?text_input=like.*João*" -Method GET

# Buscar por múltiplos status
Invoke-RestMethod -Uri "http://localhost:3000/interactions?status=in.(processed,completed)" -Method GET

# Buscar por data (últimos 7 dias)
Invoke-RestMethod -Uri "http://localhost:3000/interactions?created_at=gte.2024-01-01" -Method GET
```

## 📊 Consultas com Relacionamentos

### Seleção de Campos Específicos
```powershell
# Selecionar apenas campos específicos
Invoke-RestMethod -Uri "http://localhost:3000/interactions?select=id,text_input,status" -Method GET

# Excluir campos específicos
Invoke-RestMethod -Uri "http://localhost:3000/interactions?select=!updated_at" -Method GET
```

### Ordenação
```powershell
# Ordenar por campo específico
Invoke-RestMethod -Uri "http://localhost:3000/interactions?order=created_at.desc" -Method GET

# Ordenar por múltiplos campos
Invoke-RestMethod -Uri "http://localhost:3000/interactions?order=status.asc,created_at.desc" -Method GET
```

### Paginação
```powershell
# Limitar resultados
Invoke-RestMethod -Uri "http://localhost:3000/interactions?limit=10" -Method GET

# Pular registros (offset)
Invoke-RestMethod -Uri "http://localhost:3000/interactions?offset=10&limit=10" -Method GET
```

## 🧪 Testes Automatizados

### Verificar Status da API
```powershell
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/" -Method GET
    Write-Host "✅ PostgREST está funcionando" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgREST não está acessível" -ForegroundColor Red
}
```

### Teste Completo de CRUD
```powershell
Write-Host "🧪 Iniciando teste completo da API..." -ForegroundColor Yellow

# 1. Criar registro
$testData = @{
    text_input = "Teste automático da API"
    processed_data = '{"test": "success"}'
    status = "test"
    confidence_score = 0.9
} | ConvertTo-Json

$created = Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method POST -ContentType "application/json" -Body $testData
Write-Host "✅ Registro criado com ID: $($created.id)" -ForegroundColor Green

# 2. Buscar registro criado
$retrieved = Invoke-RestMethod -Uri "http://localhost:3000/interactions?id=eq.$($created.id)" -Method GET
Write-Host "✅ Registro recuperado: $($retrieved.text_input)" -ForegroundColor Green

# 3. Atualizar registro
$updateData = @{
    status = "updated"
    confidence_score = 0.95
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/interactions?id=eq.$($created.id)" -Method PATCH -ContentType "application/json" -Body $updateData
Write-Host "✅ Registro atualizado" -ForegroundColor Green

# 4. Deletar registro
Invoke-RestMethod -Uri "http://localhost:3000/interactions?id=eq.$($created.id)" -Method DELETE
Write-Host "✅ Registro deletado" -ForegroundColor Green

Write-Host "🎉 Teste completo realizado com sucesso!" -ForegroundColor Green
```

## 🔗 Integração com n8n

### HTTP Request Node Configuration
```json
{
  "method": "POST",
  "url": "http://localhost:3000/interactions",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "text_input": "{{ $json.text }}",
    "processed_data": "{{ $json.processed_data }}",
    "status": "{{ $json.status }}",
    "confidence_score": "{{ $json.confidence_score }}"
  }
}
```

### Exemplo de Workflow n8n
1. **Webhook** - Recebe dados
2. **OpenAI** - Processa texto
3. **HTTP Request** - Salva no PostgREST
4. **Response** - Retorna resultado

## 🚨 Tratamento de Erros

### Códigos de Status HTTP
- `200` - Sucesso
- `201` - Criado com sucesso
- `400` - Requisição inválida
- `404` - Recurso não encontrado
- `500` - Erro interno do servidor

### Exemplo de Tratamento de Erro
```powershell
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method POST -ContentType "application/json" -Body $data
    Write-Host "✅ Sucesso: $($response.id)" -ForegroundColor Green
} catch {
    $error = $_.Exception.Response
    $statusCode = $error.StatusCode.value__
    $errorMessage = $_.Exception.Message
    Write-Host "❌ Erro $statusCode: $errorMessage" -ForegroundColor Red
}
```

## 📚 Recursos Adicionais

- [Documentação oficial do PostgREST](https://postgrest.org/en/stable/)
- [Guia de filtros e consultas](https://postgrest.org/en/stable/api.html#filters)
- [Exemplos de uso avançado](https://postgrest.org/en/stable/examples.html) 