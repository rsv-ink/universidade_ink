class AddRascunhoToUniversidadeArtigos < ActiveRecord::Migration[7.0]
  def change
    add_column :universidade_artigos, :rascunho, :boolean, null: false, default: false
    add_index :universidade_artigos, :rascunho
  end
end
