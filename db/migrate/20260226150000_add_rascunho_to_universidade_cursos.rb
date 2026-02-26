class AddRascunhoToUniversidadeCursos < ActiveRecord::Migration[7.0]
  def change
    add_column :universidade_cursos, :rascunho, :boolean, null: false, default: false
    add_index :universidade_cursos, :rascunho, name: "index_universidade_cursos_on_rascunho"
  end
end
