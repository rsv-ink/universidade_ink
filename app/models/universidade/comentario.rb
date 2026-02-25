module Universidade
  class Comentario < ApplicationRecord
    self.table_name = "universidade_comentarios"

    belongs_to :artigo, class_name: "Universidade::Artigo"
    # lojista_id referencia um modelo da aplicação host.
    # Defina belongs_to :lojista com class_name apropriado se necessário,
    # ou acesse via Lojista.find(lojista_id) na aplicação host.
    validates :lojista_id, presence: true
    validates :corpo, presence: true

    # Retorna apenas o primeiro nome do lojista.
    # Requer que o model Lojista esteja acessível na aplicação host com atributo `nome`.
    # Retorna fallback seguro se o model não existir ou o registro não for encontrado.
    def primeiro_nome
      ::Lojista.find(lojista_id).nome.split.first
    rescue NameError, ActiveRecord::RecordNotFound
      "Usuário ##{lojista_id}"
    end
  end
end
