class CreateUniversidadeSecaoItens < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_secao_itens do |t|
      t.references :secao,    null: false, foreign_key: { to_table: :universidade_secoes }
      t.string     :item_type, null: false
      t.integer    :item_id,   null: false
      t.integer    :ordem

      t.timestamps
    end

    add_index :universidade_secao_itens, %i[item_type item_id]
  end
end
