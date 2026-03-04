require "universidade/version"
require "universidade/engine"

module Universidade
  # Procs configuráveis pela aplicação host.
  #
  # Exemplo de configuração no host (config/initializers/universidade.rb):
  #   Universidade.current_user_proc = ->(controller) { controller.current_user }
  #   Universidade.tracking_id_proc  = -> { ENV['GA_TRACKING_ID'] }
  #
  # O objeto retornado por current_user_proc deve responder a:
  #   .id          → ID do usuário
  #   .store_id    → ID da loja
  #   .is_admin?   → se o usuário é admin (para área administrativa)
  mattr_accessor :current_user_proc, :tracking_id_proc

  def self.current_user(controller_instance)
    current_user_proc&.call(controller_instance)
  end

  def self.tracking_id
    tracking_id_proc&.call
  end
end
