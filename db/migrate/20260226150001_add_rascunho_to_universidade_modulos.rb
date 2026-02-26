class AddRascunhoToUniversidadeModulos < ActiveRecord::Migration[7.0]
  def change
    add_column :universidade_modulos, :rascunho, :boolean, null: false, default: false
    add_index :universidade_modulos, :rascunho, name: "index_universidade_modulos_on_rascunho"
  end
end
