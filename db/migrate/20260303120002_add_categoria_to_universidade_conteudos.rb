class AddCategoriaToUniversidadeConteudos < ActiveRecord::Migration[7.2]
  def change
    add_reference :universidade_conteudos, :categoria, 
                  foreign_key: { to_table: :universidade_categorias }, 
                  null: true, 
                  index: true
  end
end
