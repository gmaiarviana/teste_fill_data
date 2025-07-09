#!/bin/bash

echo "========================================"
echo "  Sistema de Automação com n8n"
echo "========================================"
echo

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "[ERRO] Docker não está rodando!"
    echo "Por favor, inicie o Docker e tente novamente."
    exit 1
fi

# Verificar se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo "[INFO] Arquivo .env não encontrado."
    echo "Copiando env.example para .env..."
    cp env.example .env
    echo
    echo "[IMPORTANTE] Configure sua OPENAI_API_KEY no arquivo .env"
    echo "Pressione Enter para continuar..."
    read
fi

echo "[INFO] Iniciando containers..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo
    echo "========================================"
    echo "  Ambiente iniciado com sucesso!"
    echo "========================================"
    echo
    echo "[SERVIÇOS]"
    echo "- n8n: http://localhost:5678"
    echo "- n8n DB: localhost:5432"
    echo "- App DB: localhost:5433"
    echo
    echo "[CREDENCIAIS PADRÃO]"
    echo "Usuário: admin"
    echo "Senha: admin123"
    echo
    echo "[COMANDOS ÚTEIS]"
    echo "- Ver logs: docker-compose logs -f"
    echo "- Parar: docker-compose down"
    echo "- Status: docker-compose ps"
    echo
    echo "Pressione Enter para abrir o n8n..."
    read
    if command -v xdg-open > /dev/null; then
        xdg-open http://localhost:5678
    elif command -v open > /dev/null; then
        open http://localhost:5678
    else
        echo "Abra manualmente: http://localhost:5678"
    fi
else
    echo "[ERRO] Falha ao iniciar os containers!"
    echo "Verifique os logs com: docker-compose logs"
fi 