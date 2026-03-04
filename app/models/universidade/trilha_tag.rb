module Universidade
  class TrilhaTag < ApplicationRecord
    self.table_name = "universidade_trilha_tags"

    belongs_to :trilha
    belongs_to :tag

    validates :tag_id, uniqueness: { scope: :trilha_id }
  end
end
