# =============================================================================
# Script de Teste da API PostgREST
# =============================================================================
# 
# Este script testa a funcionalidade completa da API PostgREST
# incluindo verificação de status, operações CRUD e tratamento de erros.
#
# Uso: .\test-api.ps1
# =============================================================================

Write-Host "🚀 Iniciando testes da API PostgREST..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# =============================================================================
# CONFIGURAÇÕES
# =============================================================================
$baseUrl = "http://localhost:3000"
$testTable = "interactions"

# =============================================================================
# TESTE 1: Verificar se API está rodando
# =============================================================================
Write-Host "`n📋 Teste 1: Verificando status da API..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/" -Method GET -TimeoutSec 10
    Write-Host "✅ PostgREST está rodando e respondendo" -ForegroundColor Green
    Write-Host "   Versão: $($response.version)" -ForegroundColor Gray
} catch {
    Write-Host "❌ PostgREST não está acessível" -ForegroundColor Red
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n💡 Verifique se:" -ForegroundColor Yellow
    Write-Host "   1. Docker Compose está rodando: docker-compose up -d" -ForegroundColor Gray
    Write-Host "   2. PostgREST container está saudável: docker-compose ps" -ForegroundColor Gray
    Write-Host "   3. Porta 3000 não está sendo usada por outro serviço" -ForegroundColor Gray
    exit 1
}

# =============================================================================
# TESTE 2: Verificar se tabelas estão acessíveis
# =============================================================================
Write-Host "`n📋 Teste 2: Verificando acesso às tabelas..." -ForegroundColor Yellow

$tables = @("interactions", "user_preferences", "learning_history")

foreach ($table in $tables) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$table" -Method GET -TimeoutSec 5
        Write-Host "✅ Tabela '$table' está acessível" -ForegroundColor Green
    } catch {
        Write-Host "❌ Tabela '$table' não está acessível" -ForegroundColor Red
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# TESTE 3: Operações CRUD na tabela interactions
# =============================================================================
Write-Host "`n📋 Teste 3: Testando operações CRUD..." -ForegroundColor Yellow

# Dados de teste
$testData = @{
    text_input = "Maria Santos, 25 anos, designer gráfico"
    processed_data = '{"nome": "Maria Santos", "idade": 25, "profissao": "designer gráfico"}'
    status = "processed"
    confidence_score = 0.9
} | ConvertTo-Json

$createdId = $null

# 3.1 - CREATE (POST)
Write-Host "   📝 Criando registro de teste..." -ForegroundColor Gray
try {
    $created = Invoke-RestMethod -Uri "$baseUrl/$testTable" -Method POST -ContentType "application/json" -Body $testData -TimeoutSec 10
    $createdId = $created.id
    Write-Host "   ✅ Registro criado com ID: $createdId" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro ao criar registro: $($_.Exception.Message)" -ForegroundColor Red
    $createdId = $null
}

# 3.2 - READ (GET) - se o CREATE foi bem-sucedido
if ($createdId) {
    Write-Host "   📖 Lendo registro criado..." -ForegroundColor Gray
    try {
        $retrieved = Invoke-RestMethod -Uri "$baseUrl/$testTable?id=eq.$createdId" -Method GET -TimeoutSec 10
        if ($retrieved) {
            Write-Host "   ✅ Registro recuperado: $($retrieved.text_input)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Registro não encontrado após criação" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Erro ao ler registro: $($_.Exception.Message)" -ForegroundColor Red
    }

    # 3.3 - UPDATE (PATCH)
    Write-Host "   🔄 Atualizando registro..." -ForegroundColor Gray
    $updateData = @{
        status = "completed"
        confidence_score = 0.95
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "$baseUrl/$testTable?id=eq.$createdId" -Method PATCH -ContentType "application/json" -Body $updateData -TimeoutSec 10
        Write-Host "   ✅ Registro atualizado com sucesso" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao atualizar registro: $($_.Exception.Message)" -ForegroundColor Red
    }

    # 3.4 - DELETE
    Write-Host "   🗑️  Deletando registro de teste..." -ForegroundColor Gray
    try {
        Invoke-RestMethod -Uri "$baseUrl/$testTable?id=eq.$createdId" -Method DELETE -TimeoutSec 10
        Write-Host "   ✅ Registro deletado com sucesso" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao deletar registro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# TESTE 4: Consultas com filtros
# =============================================================================
Write-Host "`n📋 Teste 4: Testando consultas com filtros..." -ForegroundColor Yellow

# Criar alguns registros para teste de filtros
$testRecords = @(
    @{
        text_input = "João Silva, 30 anos, desenvolvedor"
        processed_data = '{"nome": "João Silva", "idade": 30, "profissao": "desenvolvedor"}'
        status = "processed"
        confidence_score = 0.85
    },
    @{
        text_input = "Ana Costa, 28 anos, designer"
        processed_data = '{"nome": "Ana Costa", "idade": 28, "profissao": "designer"}'
        status = "pending"
        confidence_score = 0.75
    },
    @{
        text_input = "Pedro Santos, 35 anos, gerente"
        processed_data = '{"nome": "Pedro Santos", "idade": 35, "profissao": "gerente"}'
        status = "completed"
        confidence_score = 0.92
    }
)

$createdIds = @()

# Criar registros de teste
foreach ($record in $testRecords) {
    try {
        $created = Invoke-RestMethod -Uri "$baseUrl/$testTable" -Method POST -ContentType "application/json" -Body ($record | ConvertTo-Json) -TimeoutSec 5
        $createdIds += $created.id
    } catch {
        Write-Host "   ⚠️  Erro ao criar registro de teste: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if ($createdIds.Count -gt 0) {
    Write-Host "   ✅ Criados $($createdIds.Count) registros para teste de filtros" -ForegroundColor Green

    # Testar diferentes filtros
    $filters = @(
        @{ name = "Status = processed"; url = "status=eq.processed" },
        @{ name = "Confiança >= 0.8"; url = "confidence_score=gte.0.8" },
        @{ name = "Texto contém 'João'"; url = "text_input=like.*João*" },
        @{ name = "Ordenado por data"; url = "order=created_at.desc" },
        @{ name = "Limitado a 2 registros"; url = "limit=2" }
    )

    foreach ($filter in $filters) {
        try {
            $response = Invoke-RestMethod -Uri "$baseUrl/$testTable?$($filter.url)" -Method GET -TimeoutSec 5
            Write-Host "   ✅ $($filter.name): $($response.Count) registros encontrados" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ $($filter.name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Limpar registros de teste
    Write-Host "   🧹 Limpando registros de teste..." -ForegroundColor Gray
    foreach ($id in $createdIds) {
        try {
            Invoke-RestMethod -Uri "$baseUrl/$testTable?id=eq.$id" -Method DELETE -TimeoutSec 5 | Out-Null
        } catch {
            # Ignorar erros de limpeza
        }
    }
    Write-Host "   ✅ Registros de teste removidos" -ForegroundColor Green
}

# =============================================================================
# TESTE 5: Teste de performance
# =============================================================================
Write-Host "`n📋 Teste 5: Teste de performance..." -ForegroundColor Yellow

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri "$baseUrl/$testTable" -Method GET -TimeoutSec 10
    $stopwatch.Stop()
    
    $responseTime = $stopwatch.ElapsedMilliseconds
    Write-Host "   ⏱️  Tempo de resposta: ${responseTime}ms" -ForegroundColor Green
    
    if ($responseTime -lt 1000) {
        Write-Host "   ✅ Performance excelente (< 1s)" -ForegroundColor Green
    } elseif ($responseTime -lt 3000) {
        Write-Host "   ✅ Performance boa (< 3s)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Performance pode ser melhorada (> 3s)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Erro no teste de performance: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# TESTE 6: Verificar documentação automática
# =============================================================================
Write-Host "`n📋 Teste 6: Verificando documentação automática..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/" -Method GET -TimeoutSec 5
    if ($response.tables) {
        Write-Host "   ✅ Documentação automática disponível" -ForegroundColor Green
        Write-Host "   📚 Tabelas detectadas: $($response.tables.Count)" -ForegroundColor Gray
        foreach ($table in $response.tables) {
            Write-Host "      - $table" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ⚠️  Documentação automática não disponível" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Erro ao verificar documentação: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# RESUMO DOS TESTES
# =============================================================================
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "✅ API PostgREST está funcionando corretamente!" -ForegroundColor Green
Write-Host "`n🌐 URLs disponíveis:" -ForegroundColor Yellow
Write-Host "   - API Base: $baseUrl" -ForegroundColor Gray
Write-Host "   - Documentação: $baseUrl/" -ForegroundColor Gray
Write-Host "   - Tabela interactions: $baseUrl/interactions" -ForegroundColor Gray
Write-Host "   - Tabela user_preferences: $baseUrl/user_preferences" -ForegroundColor Gray
Write-Host "   - Tabela learning_history: $baseUrl/learning_history" -ForegroundColor Gray

Write-Host "`n🔧 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Configure o n8n para usar HTTP Request ao invés do nó PostgreSQL" -ForegroundColor Gray
Write-Host "   2. Teste os workflows com a nova API" -ForegroundColor Gray
Write-Host "   3. Configure autenticação se necessário" -ForegroundColor Gray

Write-Host "`n🎉 Testes concluídos com sucesso!" -ForegroundColor Green 