# frozen_string_literal: true

# Configuracao mock para testes da engine Universidade.
# Em producao, a aplicacao host deve configurar isso para retornar user/store reais.

Universidade.current_user_id_proc = lambda do |_controller|
  1
end

Universidade.current_store_id_proc = lambda do |_controller|
  1
end
