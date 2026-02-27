class AddSubtituloAndLayoutToUniversidadeSecoes < ActiveRecord::Migration[7.0]
  def up
    add_column :universidade_secoes, :subtitulo, :string
    add_column :universidade_secoes, :layout_exibicao, :string, null: false, default: "galeria"

    execute "UPDATE universidade_secoes SET formato_card = 'quadrado' WHERE formato_card = 'horizontal'"
  end

  def down
    remove_column :universidade_secoes, :subtitulo
    remove_column :universidade_secoes, :layout_exibicao
  end
end
