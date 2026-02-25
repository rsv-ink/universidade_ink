# frozen_string_literal: true

# Configuração mock para testes da engine Universidade
# Em produção, a aplicação host deve configurar isso para retornar o lojista real.

Universidade.current_lojista_id_proc = lambda do |_controller|
  # Mock fixo para desenvolvimento e testes
  # Representa um lojista fictício com ID = 1
  1
end
