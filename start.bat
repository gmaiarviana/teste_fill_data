@echo off
echo ========================================
echo   Sistema de Automacao com n8n
echo ========================================
echo.

REM Verificar se o Docker está rodando
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Docker nao esta rodando!
    echo Por favor, inicie o Docker Desktop e tente novamente.
    pause
    exit /b 1
)

REM Verificar se o arquivo .env existe
if not exist ".env" (
    echo [INFO] Arquivo .env nao encontrado.
    echo Copiando env.example para .env...
    copy env.example .env
    echo.
    echo [IMPORTANTE] Configure sua OPENAI_API_KEY no arquivo .env
    echo Pressione qualquer tecla para continuar...
    pause >nul
)

echo [INFO] Iniciando containers...
docker-compose up -d

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   Ambiente iniciado com sucesso!
    echo ========================================
    echo.
    echo [SERVICOS]
    echo - n8n: http://localhost:5678
    echo - n8n DB: localhost:5432
    echo - App DB: localhost:5433
    echo.
    echo [CREDENCIAIS PADRAO]
    echo Usuario: admin
    echo Senha: admin123
    echo.
    echo [COMANDOS UTEIS]
    echo - Ver logs: docker-compose logs -f
    echo - Parar: docker-compose down
    echo - Status: docker-compose ps
    echo.
    echo Pressione qualquer tecla para abrir o n8n...
    pause >nul
    start http://localhost:5678
) else (
    echo [ERRO] Falha ao iniciar os containers!
    echo Verifique os logs com: docker-compose logs
    pause
) 