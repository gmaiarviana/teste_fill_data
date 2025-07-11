# 🧪 Casos de Teste Manuais - Auto Copilot Experiment

Comandos PowerShell para testar manualmente cada fase do experimento.

---

## 🔧 Comandos de Verificação Inicial

### Verificar se serviços estão rodando
```powershell
# Verificar n8n
Invoke-RestMethod -Uri "http://localhost:5678/healthz" -Method GET

# Verificar PostgREST
Invoke-RestMethod -Uri "http://localhost:3000/" -Method GET

# Limpar banco para teste limpo (opcional)
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method DELETE
```

### Verificar dados no banco
```powershell
# Ver todos os registros
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET

# Ver últimos 5 registros
Invoke-RestMethod -Uri "http://localhost:3000/interactions?order=created_at.desc&limit=5" -Method GET
```

---

## 🐕 FASE 1: Automação Básica - Animais

**Objetivo**: Extração de campos fixos (nome, idade, profissão)

### Caso 1.1: Animal doméstico simples
```powershell
$payload = @{
    text = "Max, 3 anos, Golden Retriever"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase1" -Method POST -ContentType "application/json" -Body $payload
```

**Resultado esperado:**
- Status: `processed`
- Dados extraídos: nome="Max", idade=3, profissao="Golden Retriever"

### Verificar dados salvos
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/interactions?order=created_at.desc&limit=1" -Method GET
```

---

## 🍕 FASE 2: Campos Dinâmicos + Auto-validação - Comida

**Objetivo**: Campos configuráveis + sistema de confiança

### Caso 2.1: Alta confiança - Receita completa
```powershell
$payload = @{
    text = "Pizza Margherita, italiana, 25 minutos, massa, tomate, mozzarella, manjericao"
    fields = @("nome", "origem", "tempo_preparo", "ingredientes_principais", "dificuldade")
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase2" -Method POST -ContentType "application/json" -Body $payload
```

**Resultado esperado:**
- Status: `completed` 
- Confidence: ≥ 0.8
- Dados bem estruturados

### Caso 2.2: Baixa confiança - Dados ambíguos
```powershell
$payload = @{
    text = "Aquela sobremesa francesa que é muito boa e demorada"
    fields = @("nome", "origem", "tempo_preparo", "tipo", "dificuldade", "ingredientes_principais")
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase2" -Method POST -ContentType "application/json" -Body $payload
```

**Resultado esperado:**
- Status: `validating`
- Confidence: < 0.8
- Pergunta de esclarecimento gerada

### Verificar dados da Fase 2
```powershell
# Ver registros por status
Invoke-RestMethod -Uri "http://localhost:3000/interactions?status=eq.completed" -Method GET
Invoke-RestMethod -Uri "http://localhost:3000/interactions?status=eq.validating" -Method GET
```

---

## 🐉 FASE 3: Contexto e Aprendizado - Pokémon

**Objetivo**: Sistema usa histórico para melhorar extração

### Caso 3.1: Primeira interação (sem contexto)
```powershell
$payload = @{
    text = "Pikachu eletrico nivel 25 habilidade Static"
    fields = @("nome", "tipo", "nivel", "habilidade", "regiao", "evolucao")
    user_id = "treinador_ash_001"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase3" -Method POST -ContentType "application/json" -Body $payload
```

**Resultado esperado:**
- Confidence: baseline (sem bonus de contexto)
- context_used: false

### Caso 3.2: Segunda interação (com contexto)
```powershell
$payload = @{
    text = "Charizard fogo e voador nivel 50 de Kanto"
    fields = @("nome", "tipo", "nivel", "habilidade", "regiao", "evolucao")
    user_id = "treinador_ash_001"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase3" -Method POST -ContentType "application/json" -Body $payload
```

**Resultado esperado:**
- Confidence: +0.1 bonus por contexto
- context_used: true
- Sistema deveria reconhecer padrões

### Caso 3.3: Terceira interação (sistema experiente)
```powershell
$payload = @{
    text = "Blastoise agua nivel 55 Kanto evolucao final de Squirtle"
    fields = @("nome", "tipo", "nivel", "habilidade", "regiao", "evolucao")
    user_id = "treinador_ash_001"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/fase3" -Method POST -ContentType "application/json" -Body $payload
```

**Resultado esperado:**
- Confidence: ainda mais alta
- context_used: true
- Extração mais precisa

### Análise de evolução do usuário
```powershell
# Buscar todos os registros do usuário específico
$allRecords = Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET
$userRecords = $allRecords | Where-Object { $_.user_id -eq "treinador_ash_001" } | Sort-Object created_at

# Mostrar evolução da confiança
$userRecords | ForEach-Object { 
    Write-Host "Confidence: $($_.confidence_score) | Context: $($_.context_used)" 
}
```

---

## 📊 Comandos de Análise Final

### Verificar todos os dados criados
```powershell
# Contar registros por fase
$all = Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET
Write-Host "Total de registros: $($all.Count)"

# Agrupar por status
$all | Group-Object status | ForEach-Object { 
    Write-Host "$($_.Name): $($_.Count) registros" 
}
```

### Verificar performance por confiança
```powershell
# Registros com alta confiança (≥ 0.8)
$highConfidence = $all | Where-Object { $_.confidence_score -ge 0.8 }
Write-Host "Alta confiança: $($highConfidence.Count) registros"

# Registros com contexto usado
$withContext = $all | Where-Object { $_.context_used -eq $true }
Write-Host "Com contexto: $($withContext.Count) registros"
```

### Limpar dados de teste (se necessário)
```powershell
# Deletar todos os registros
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method DELETE

# Ou deletar apenas do usuário específico
# (PostgREST não suporta DELETE com filtro complexo diretamente)
```

---

## 🎯 Checklist de Validação

### ✅ Fase 1 - Automação Básica
- [ ] Webhook responde em < 5 segundos
- [ ] Dados extraídos salvos no banco
- [ ] Status = "processed"
- [ ] Campos básicos preenchidos

### ✅ Fase 2 - Auto-validação  
- [ ] Sistema diferencia alta vs baixa confiança
- [ ] Status "completed" para confiança ≥ 0.8
- [ ] Status "validating" para confiança < 0.8
- [ ] Pergunta gerada para casos ambíguos
- [ ] Campos dinâmicos funcionando

### ✅ Fase 3 - Aprendizado
- [ ] context_used = false na primeira interação
- [ ] context_used = true nas seguintes
- [ ] Melhoria na confiança ao longo das interações
- [ ] user_id sendo salvo corretamente
- [ ] Sistema busca histórico anterior

---

## 🚨 Troubleshooting

### Webhook não responde
```powershell
# Verificar se n8n está ativo
docker-compose ps n8n

# Ver logs do n8n
docker-compose logs -f n8n
```

### Banco não salva dados
```powershell
# Verificar PostgREST
docker-compose ps postgrest

# Testar conexão direta
Invoke-RestMethod -Uri "http://localhost:3000/interactions" -Method GET
```

### Resetar ambiente
```powershell
# Parar e reiniciar tudo
docker-compose down
docker-compose up -d

# Aguardar inicialização (30-60 segundos)
```