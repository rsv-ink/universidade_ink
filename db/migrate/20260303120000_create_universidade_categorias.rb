class CreateUniversidadeCategorias < ActiveRecord::Migration[7.2]
  def change
    create_table :universidade_categorias do |t|
      t.string :nome, null: false
      t.string :slug, null: false
      t.text :descricao

      t.timestamps
    end

    add_index :universidade_categorias, :slug, unique: true
    add_index :universidade_categorias, :nome, unique: true
  end
end
