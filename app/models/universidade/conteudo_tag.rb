module Universidade
  class ConteudoTag < ApplicationRecord
    self.table_name = "universidade_conteudo_tags"
    
    # Associations
    belongs_to :conteudo
    belongs_to :tag

    # Validations
    validates :tag_id, uniqueness: { scope: :conteudo_id }
  end
end
