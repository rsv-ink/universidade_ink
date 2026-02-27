require "universidade/version"
require "universidade/engine"

module Universidade
  # Procs configuraveis pela aplicacao host para retornar os IDs atuais.
  #
  # Exemplo de configuracao no host (config/initializers/universidade.rb):
  #   Universidade.current_user_id_proc  = ->(controller) { controller.current_user&.id }
  #   Universidade.current_store_id_proc = ->(controller) { controller.current_store&.id }
  mattr_accessor :current_user_proc, :current_user_id_proc, :current_store_id_proc

  def self.current_user(controller_instance)
    current_user_proc&.call(controller_instance)
  end

  def self.current_user_id(controller_instance)
    current_user_id_proc&.call(controller_instance)
  end

  def self.current_store_id(controller_instance)
    current_store_id_proc&.call(controller_instance)
  end
end
