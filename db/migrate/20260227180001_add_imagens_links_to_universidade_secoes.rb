class AddImagensLinksToUniversidadeSecoes < ActiveRecord::Migration[7.2]
  def change
    add_column :universidade_secoes, :imagens_links, :text, default: '{}'
  end
end
