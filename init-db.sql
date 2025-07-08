-- Inicialização do banco de dados SQLite para agendamentos
-- Este arquivo é executado automaticamente pelo Docker

CREATE TABLE IF NOT EXISTS agendamentos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    telefone TEXT NOT NULL,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    observacoes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_agendamentos_data ON agendamentos(data);
CREATE INDEX IF NOT EXISTS idx_agendamentos_created_at ON agendamentos(created_at);

-- Inserir alguns dados de exemplo (opcional)
INSERT OR IGNORE INTO agendamentos (nome, telefone, data, horario, observacoes) VALUES
    ('João Silva', '(11) 99999-1111', '2024-01-15', '14:00', 'Primeira consulta'),
    ('Maria Santos', '(11) 99999-2222', '2024-01-16', '10:30', 'Retorno'),
    ('Pedro Costa', '(11) 99999-3333', '2024-01-17', '16:00', 'Consulta de rotina'); 