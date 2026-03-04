class AddColunasGaleriaToUniversidadeSecoes < ActiveRecord::Migration[7.2]
  def change
    add_column :universidade_secoes, :colunas_galeria, :integer, null: false, default: 3
  end
end
