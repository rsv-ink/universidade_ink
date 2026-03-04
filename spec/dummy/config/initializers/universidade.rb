# frozen_string_literal: true

# Configuracao mock para testes da engine Universidade.
# Em producao, a aplicacao host deve configurar isso para retornar user/store reais.

# Mock user object for development
MockUser = Struct.new(:id, :store_id, :first_name, :last_name, :email, keyword_init: true) do
  def is_admin? = true
end

Universidade.current_user_proc = lambda do |_controller|
  MockUser.new(
    id: 1,
    store_id: 1,
    first_name: "Luiza",
    last_name: "Cabral",
    email: "luiza.cabral@reserva.ink"
  )
end
