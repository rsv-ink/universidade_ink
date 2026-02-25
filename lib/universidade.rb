require "universidade/version"
require "universidade/engine"

module Universidade
  # Proc configurável pela aplicação host para retornar o ID do lojista atual.
  #
  # Exemplo de configuração no host (config/initializers/universidade.rb):
  #   Universidade.current_lojista_id_proc = ->(controller) { controller.current_lojista&.id }
  mattr_accessor :current_lojista_id_proc

  def self.current_lojista_id(controller_instance)
    current_lojista_id_proc&.call(controller_instance)
  end
end
