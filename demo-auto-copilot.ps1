# =============================================================================
# AUTO COPILOT EXPERIMENT - PIPEFY LOW CODE SQUAD
# =============================================================================
# Script automatizado para demonstrar a evolucao das 3 fases do experimento
# Contexto: Sistema de extracao inteligente com aprendizado progressivo
# =============================================================================

# Configuracao do terminal
$Host.UI.RawUI.WindowTitle = "Auto Copilot Demo - Pipefy Low Code Squad"
Clear-Host

# URLs dos webhooks
$fase1Url = "http://localhost:5678/webhook/fase1"
$fase2Url = "http://localhost:5678/webhook/fase2" 
$fase3Url = "http://localhost:5678/webhook/fase3"
$apiUrl = "http://localhost:3000/interactions"

# Funcao para exibir banner
function Show-Banner {
    param($title, $subtitle = "")
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "AUTO COPILOT: $title" -ForegroundColor Yellow
    if ($subtitle) { Write-Host "   $subtitle" -ForegroundColor Gray }
    Write-Host ("=" * 80) -ForegroundColor Cyan
}

# Funcao para aguardar entrada do usuario
function Wait-Demo {
    param($message = "Pressione ENTER para continuar...")
    Write-Host "`nPROXIMO PASSO: $message" -ForegroundColor Yellow
    Read-Host | Out-Null
}

# Funcao para enviar requisicao e mostrar resultado
function Send-Request {
    param($url, $payload, $caseName)
    
    Write-Host "`nENVIANDO: $caseName..." -ForegroundColor Green
    Write-Host "TEXTO: '$($payload.text)'" -ForegroundColor Gray
    
    if ($payload.fields) {
        Write-Host "CAMPOS: $($payload.fields -join ', ')" -ForegroundColor Gray
    }
    
    try {
        $jsonBody = $payload | ConvertTo-Json -Compress
        Write-Host "URL: $url" -ForegroundColor DarkGray
        
        $response = Invoke-RestMethod -Uri $url -Method POST -ContentType "application/json" -Body $jsonBody -TimeoutSec 20
        
        Write-Host "`nRESPOSTA RECEBIDA:" -ForegroundColor Green
        Write-Host "   STATUS: $($response.status)" -ForegroundColor Cyan
        Write-Host "   CONFIANCA: $($response.confidence)" -ForegroundColor Cyan
        Write-Host "   DADOS: $($response.extracted_data | ConvertTo-Json -Compress)" -ForegroundColor Cyan
        
        if ($response.status -eq "validating" -and $response.clarification_question) {
            Write-Host "   PERGUNTA: $($response.clarification_question)" -ForegroundColor Yellow
        }
        
        return $response
        
    } catch {
        Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Funcao para verificar dados no banco
function Check-Database {
    param($recordCount = 3)
    
    Write-Host "`nVERIFICANDO dados salvos no banco..." -ForegroundColor Blue
    
    try {
        $records = Invoke-RestMethod -Uri "$apiUrl?order=created_at.desc&limit=$recordCount" -Method GET -TimeoutSec 10
        
        if ($records.Count -gt 0) {
            Write-Host "ENCONTRADOS: $($records.Count) registro(s)" -ForegroundColor Green
            
            for ($i = 0; $i -lt [Math]::Min($records.Count, $recordCount); $i++) {
                $record = $records[$i]
                Write-Host "`n   REGISTRO $($i + 1):" -ForegroundColor Gray
                Write-Host "      ID: $($record.id)" -ForegroundColor DarkGray
                Write-Host "      TEXTO: $($record.text_input)" -ForegroundColor DarkGray
                Write-Host "      STATUS: $($record.status)" -ForegroundColor DarkGray
                Write-Host "      CONFIANCA: $($record.confidence_score)" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "AVISO: Nenhum registro encontrado" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "ERRO ao acessar banco: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =============================================================================
# INICIO DA DEMONSTRACAO
# =============================================================================

Show-Banner "AUTO COPILOT EXPERIMENT" "Extracao Inteligente de Dados com IA"

Write-Host @"
OBJETIVO: Demonstrar sistema de extracao que evolui em 3 fases:

   FASE 1: Automacao Basica (campos fixos)
   FASE 2: Campos Dinamicos + Auto-validacao  
   FASE 3: Contexto e Aprendizado

CONTEXTO: Sistema ludico para diferentes dominios
"@ -ForegroundColor White

Wait-Demo "Pronto para comecar a demonstracao?"

# =============================================================================
# FASE 1: AUTOMACAO BASICA - ANIMAIS
# =============================================================================

Show-Banner "FASE 1: AUTOMACAO BASICA" "Extracao de campos fixos - Cadastro de Animais"

Write-Host @"
CARACTERISTICAS DA FASE 1:
   • Campos fixos pre-definidos
   • Processamento direto sem validacao
   • Foco na automacao basica
   
CASO DE TESTE: Cadastro de animal domestico
"@ -ForegroundColor White

Wait-Demo "Vamos testar a Fase 1?"

# Caso 1.1: Animal domestico simples
$caso1 = @{
    text = "Max, 3 anos, Golden Retriever"
}

Send-Request -url $fase1Url -payload $caso1 -caseName "Cadastro de Animal - Max o Golden"

Check-Database -recordCount 1

Wait-Demo "Fase 1 concluida! Vamos para a Fase 2?"

# =============================================================================
# FASE 2: CAMPOS DINAMICOS + AUTO-VALIDACAO - COMIDA
# =============================================================================

Show-Banner "FASE 2: CAMPOS DINAMICOS + AUTO-VALIDACAO" "IA avalia propria confianca - Receitas e Pratos"

Write-Host @"
CARACTERISTICAS DA FASE 2:
   • Campos configuráveis pelo usuario
   • IA avalia propria confianca (0.0 a 1.0)
   • Auto-validacao: alta confianca = completed | baixa = validating
   • Gera perguntas de esclarecimento quando necessario
   
CONTEXTO: Sistema de cadastro de receitas e pratos
"@ -ForegroundColor White

Wait-Demo "Vamos testar cenarios de alta e baixa confianca?"

# Caso 2.1: Alta confianca - dados claros
Write-Host "`nCASO 2.1: ALTA CONFIANCA (dados claros)" -ForegroundColor Cyan

$caso2_1 = @{
    text = "Pizza Margherita, italiana, 25 minutos, massa, tomate, mozzarella, manjericao"
    fields = @("nome", "origem", "tempo_preparo", "ingredientes_principais", "dificuldade")
}

Send-Request -url $fase2Url -payload $caso2_1 -caseName "Receita com dados completos"

Wait-Demo "Agora vamos testar um caso com dados ambiguos..."

# Caso 2.2: Baixa confianca - dados ambiguos  
Write-Host "`nCASO 2.2: BAIXA CONFIANCA (dados ambiguos)" -ForegroundColor Cyan

$caso2_2 = @{
    text = "Aquela sobremesa francesa que é muito boa e demorada"
    fields = @("nome", "origem", "tempo_preparo", "tipo", "dificuldade", "ingredientes_principais")
}

Send-Request -url $fase2Url -payload $caso2_2 -caseName "Receita com dados incompletos"

Check-Database -recordCount 3

Wait-Demo "Fase 2 concluida! Vamos para a Fase 3 - o sistema inteligente?"

# =============================================================================
# FASE 3: CONTEXTO E APRENDIZADO - POKEMON
# =============================================================================

Show-Banner "FASE 3: CONTEXTO E APRENDIZADO" "Sistema usa historico para melhorar extracao - Pokedex"

Write-Host @"
CARACTERISTICAS DA FASE 3:
   • Sistema busca interacoes anteriores do mesmo usuario
   • Usa contexto para melhorar confianca (+0.1 bonus)
   • Aprende padroes e melhora ao longo do tempo
   • Personalizacao baseada no historico
   
CONTEXTO: Sistema de cadastro Pokemon para treinadores
"@ -ForegroundColor White

Wait-Demo "Vamos simular um treinador retornando com mais Pokemon?"

# Caso 3.1: Primeira interacao do usuario (sem contexto)
Write-Host "`nCASO 3.1: PRIMEIRA INTERACAO (sem contexto)" -ForegroundColor Cyan

$caso3_1 = @{
    text = "Pikachu eletrico nivel 25 habilidade Static"
    fields = @("nome", "tipo", "nivel", "habilidade", "regiao", "evolucao")
    user_id = "treinador_ash_001"
}

Send-Request -url $fase3Url -payload $caso3_1 -caseName "Primeira interacao - Pikachu"

Wait-Demo "Agora vamos adicionar mais um Pokemon do mesmo treinador..."

# Caso 3.2: Segunda interacao do mesmo usuario (com contexto)
Write-Host "`nCASO 3.2: SEGUNDA INTERACAO (com contexto)" -ForegroundColor Cyan

$caso3_2 = @{
    text = "Charizard fogo e voador nivel 50 de Kanto"
    fields = @("nome", "tipo", "nivel", "habilidade", "regiao", "evolucao")
    user_id = "treinador_ash_001"
}

Send-Request -url $fase3Url -payload $caso3_2 -caseName "Segunda interacao - Charizard (com contexto)"

Wait-Demo "Uma ultima interacao para mostrar o aprendizado..."

# Caso 3.3: Terceira interacao - sistema deveria ter alta confianca
Write-Host "`nCASO 3.3: TERCEIRA INTERACAO (sistema experiente)" -ForegroundColor Cyan

$caso3_3 = @{
    text = "Blastoise agua nivel 55 Kanto evolucao final de Squirtle"
    fields = @("nome", "tipo", "nivel", "habilidade", "regiao", "evolucao")
    user_id = "treinador_ash_001"
}

Send-Request -url $fase3Url -payload $caso3_3 -caseName "Terceira interacao - Blastoise (sistema experiente)"

# Verificacao final do banco
Write-Host "`nVERIFICACAO FINAL DO BANCO DE DADOS" -ForegroundColor Magenta
Check-Database -recordCount 6

# Mostrar evolucao da confianca
Write-Host "`nANALISE DE EVOLUCAO:" -ForegroundColor Magenta

try {
    $userRecords = Invoke-RestMethod -Uri "$apiUrl" -Method GET -TimeoutSec 10
    $filteredRecords = $userRecords | Where-Object { $_.user_id -eq "treinador_ash_001" } | Sort-Object created_at
    
    if ($filteredRecords.Count -gt 0) {
        Write-Host "REGISTROS do usuario treinador_ash_001:" -ForegroundColor Green
        
        for ($i = 0; $i -lt $filteredRecords.Count; $i++) {
            $record = $filteredRecords[$i]
            $contextUsed = if ($record.context_used) { "COM contexto" } else { "SEM contexto" }
            Write-Host "   $($i + 1). CONFIANCA: $($record.confidence_score) | $contextUsed" -ForegroundColor Gray
        }
        
        if ($filteredRecords.Count -gt 1) {
            $firstConfidence = $filteredRecords[0].confidence_score
            $lastConfidence = $filteredRecords[-1].confidence_score
            $improvement = $lastConfidence - $firstConfidence
            
            Write-Host "`nMELHORIA na confianca: $([math]::Round($improvement, 2))" -ForegroundColor Cyan
            
            if ($improvement -gt 0) {
                Write-Host "SUCESSO: Sistema melhorou com o contexto!" -ForegroundColor Green
            }
        }
    }
    
} catch {
    Write-Host "ERRO na analise: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# CONCLUSAO DA DEMONSTRACAO
# =============================================================================

Show-Banner "DEMONSTRACAO CONCLUIDA" "Sistema Auto Copilot funcionando em 3 fases"

Write-Host @"
RESUMO DOS RESULTADOS:

   FASE 1: Automacao basica funcionando
      • Extracao de campos fixos
      • Processamento direto e eficiente
      
   FASE 2: Sistema inteligente com auto-validacao
      • Campos dinamicos configuráveis
      • Auto-avaliacao de confianca
      • Geracao de perguntas de esclarecimento
      
   FASE 3: Aprendizado e contexto
      • Uso de historico para melhorar precisao
      • Bonus de confianca com contexto
      • Personalizacao por usuario

PROXIMOS PASSOS:
   • Implementar endpoint de feedback para correcoes
   • Adicionar sistema de preferencias por usuario  
   • Expandir capacidades de aprendizado de padroes
   • Integracao com Pipefy para workflows reais

"@ -ForegroundColor White

Write-Host "DEMONSTRACAO finalizada com sucesso!" -ForegroundColor Green
Write-Host "DADOS salvos no PostgreSQL e acessiveis via API" -ForegroundColor Gray
Write-Host "API: http://localhost:3000/interactions" -ForegroundColor Gray

Wait-Demo "Pressione ENTER para finalizar a demonstracao"

Write-Host "`nObrigado pela atencao! Auto Copilot Experiment - Pipefy Low Code Squad" -ForegroundColor Yellow