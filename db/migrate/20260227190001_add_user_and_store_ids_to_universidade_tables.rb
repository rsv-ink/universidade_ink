class AddUserAndStoreIdsToUniversidadeTables < ActiveRecord::Migration[7.0]
  def up
    add_column :universidade_cursos, :user_id, :integer
    add_column :universidade_cursos, :store_id, :integer
    add_column :universidade_modulos, :user_id, :integer
    add_column :universidade_modulos, :store_id, :integer
    add_column :universidade_trilhas, :user_id, :integer
    add_column :universidade_trilhas, :store_id, :integer
    add_column :universidade_artigos, :user_id, :integer
    add_column :universidade_artigos, :store_id, :integer
    add_column :universidade_secoes, :user_id, :integer
    add_column :universidade_secoes, :store_id, :integer
    add_column :universidade_secao_itens, :user_id, :integer
    add_column :universidade_secao_itens, :store_id, :integer

    execute "UPDATE universidade_cursos SET user_id = 1, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    execute "UPDATE universidade_modulos SET user_id = 1, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    execute "UPDATE universidade_trilhas SET user_id = 1, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    execute "UPDATE universidade_artigos SET user_id = 1, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    execute "UPDATE universidade_secoes SET user_id = 1, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    execute "UPDATE universidade_secao_itens SET user_id = 1, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"

    change_column_null :universidade_cursos, :user_id, false
    change_column_null :universidade_cursos, :store_id, false
    change_column_null :universidade_modulos, :user_id, false
    change_column_null :universidade_modulos, :store_id, false
    change_column_null :universidade_trilhas, :user_id, false
    change_column_null :universidade_trilhas, :store_id, false
    change_column_null :universidade_artigos, :user_id, false
    change_column_null :universidade_artigos, :store_id, false
    change_column_null :universidade_secoes, :user_id, false
    change_column_null :universidade_secoes, :store_id, false
    change_column_null :universidade_secao_itens, :user_id, false
    change_column_null :universidade_secao_itens, :store_id, false

    add_index :universidade_cursos, :user_id
    add_index :universidade_cursos, :store_id
    add_index :universidade_modulos, :user_id
    add_index :universidade_modulos, :store_id
    add_index :universidade_trilhas, :user_id
    add_index :universidade_trilhas, :store_id
    add_index :universidade_artigos, :user_id
    add_index :universidade_artigos, :store_id
    add_index :universidade_secoes, :user_id
    add_index :universidade_secoes, :store_id
    add_index :universidade_secao_itens, :user_id
    add_index :universidade_secao_itens, :store_id

    add_column :universidade_progressos, :user_id, :integer
    add_column :universidade_progressos, :store_id, :integer
    execute "UPDATE universidade_progressos SET user_id = lojista_id, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    remove_index :universidade_progressos, column: [:lojista_id, :artigo_id]
    remove_index :universidade_progressos, :lojista_id
    remove_column :universidade_progressos, :lojista_id, :integer
    change_column_null :universidade_progressos, :user_id, false
    change_column_null :universidade_progressos, :store_id, false
    add_index :universidade_progressos, [:user_id, :artigo_id, :store_id], unique: true, name: "index_universidade_progressos_on_user_artigo_store"
    add_index :universidade_progressos, :user_id
    add_index :universidade_progressos, :store_id

    add_column :universidade_feedbacks, :user_id, :integer
    add_column :universidade_feedbacks, :store_id, :integer
    execute "UPDATE universidade_feedbacks SET user_id = lojista_id, store_id = 1 WHERE user_id IS NULL OR store_id IS NULL"
    remove_index :universidade_feedbacks, column: [:artigo_id, :lojista_id]
    remove_column :universidade_feedbacks, :lojista_id, :integer
    change_column_null :universidade_feedbacks, :user_id, false
    change_column_null :universidade_feedbacks, :store_id, false
    add_index :universidade_feedbacks, [:artigo_id, :user_id, :store_id], unique: true, name: "index_universidade_feedbacks_on_artigo_user_store"
    add_index :universidade_feedbacks, :user_id
    add_index :universidade_feedbacks, :store_id
  end

  def down
    remove_index :universidade_feedbacks, name: "index_universidade_feedbacks_on_artigo_user_store"
    remove_index :universidade_feedbacks, :user_id
    remove_index :universidade_feedbacks, :store_id
    add_column :universidade_feedbacks, :lojista_id, :integer, null: false
    add_index :universidade_feedbacks, [:artigo_id, :lojista_id], unique: true
    remove_column :universidade_feedbacks, :user_id, :integer
    remove_column :universidade_feedbacks, :store_id, :integer

    remove_index :universidade_progressos, name: "index_universidade_progressos_on_user_artigo_store"
    remove_index :universidade_progressos, :user_id
    remove_index :universidade_progressos, :store_id
    add_column :universidade_progressos, :lojista_id, :integer, null: false
    add_index :universidade_progressos, [:lojista_id, :artigo_id], unique: true
    add_index :universidade_progressos, :lojista_id
    remove_column :universidade_progressos, :user_id, :integer
    remove_column :universidade_progressos, :store_id, :integer

    remove_index :universidade_secao_itens, :user_id
    remove_index :universidade_secao_itens, :store_id
    remove_column :universidade_secao_itens, :user_id, :integer
    remove_column :universidade_secao_itens, :store_id, :integer

    remove_index :universidade_secoes, :user_id
    remove_index :universidade_secoes, :store_id
    remove_column :universidade_secoes, :user_id, :integer
    remove_column :universidade_secoes, :store_id, :integer

    remove_index :universidade_artigos, :user_id
    remove_index :universidade_artigos, :store_id
    remove_column :universidade_artigos, :user_id, :integer
    remove_column :universidade_artigos, :store_id, :integer

    remove_index :universidade_trilhas, :user_id
    remove_index :universidade_trilhas, :store_id
    remove_column :universidade_trilhas, :user_id, :integer
    remove_column :universidade_trilhas, :store_id, :integer

    remove_index :universidade_modulos, :user_id
    remove_index :universidade_modulos, :store_id
    remove_column :universidade_modulos, :user_id, :integer
    remove_column :universidade_modulos, :store_id, :integer

    remove_index :universidade_cursos, :user_id
    remove_index :universidade_cursos, :store_id
    remove_column :universidade_cursos, :user_id, :integer
    remove_column :universidade_cursos, :store_id, :integer
  end
end
