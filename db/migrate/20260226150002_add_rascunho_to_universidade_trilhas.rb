class AddRascunhoToUniversidadeTrilhas < ActiveRecord::Migration[7.0]
  def change
    add_column :universidade_trilhas, :rascunho, :boolean, null: false, default: false
    add_index :universidade_trilhas, :rascunho, name: "index_universidade_trilhas_on_rascunho"
  end
end
