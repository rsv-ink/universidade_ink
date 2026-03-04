class AddColunasGaleriaMobileToUniversidadeSecoes < ActiveRecord::Migration[7.1]
  def change
    add_column :universidade_secoes, :colunas_galeria_mobile, :integer, null: false, default: 1
  end
end
