class RefactorHierarchyRenameEntities < ActiveRecord::Migration[7.2]
  def up
    # 1. Remover FK constraints
    remove_foreign_key :universidade_modulos,   :universidade_cursos,    column: :curso_id
    remove_foreign_key :universidade_trilhas,   :universidade_modulos,   column: :modulo_id
    remove_foreign_key :universidade_artigos,   :universidade_trilhas,   column: :trilha_id
    remove_foreign_key :universidade_progressos, :universidade_artigos  # artigo_id (auto-detecta coluna)
    remove_foreign_key :universidade_progressos, :universidade_trilhas  # trilha_id (especifica tabela old trilhas)
    # Nota: feedbacks não tem FK, só índices

    # 2. Drop tabela antiga universidade_trilhas
    drop_table :universidade_trilhas

    # 3. Renomear tabelas principais
    rename_table :universidade_cursos,   :universidade_trilhas
    rename_table :universidade_artigos,  :universidade_conteudos

    # 4. modulos: curso_id → trilha_id (aponta para nova tabela trilhas)
    rename_column :universidade_modulos, :curso_id, :trilha_id

    # 5. conteudos (era artigos): trilha_id (apontava para trilha antiga) → modulo_id
    rename_column :universidade_conteudos, :trilha_id, :modulo_id
    # 5b. Adicionar trilha_id para conteúdos soltos diretamente em uma trilha
    add_column    :universidade_conteudos, :trilha_id, :bigint, null: true
    add_index     :universidade_conteudos, :trilha_id

    # 6. progressos: artigo_id → conteudo_id; recriar índice único
    remove_index  :universidade_progressos, name: :index_universidade_progressos_on_user_artigo_store
    rename_column :universidade_progressos, :artigo_id, :conteudo_id
    add_index     :universidade_progressos, [:user_id, :conteudo_id, :store_id], unique: true, name: :index_universidade_progressos_on_user_conteudo_store

    # 7. feedbacks: artigo_id → conteudo_id; recriar índice único
    remove_index  :universidade_feedbacks, name: :index_universidade_feedbacks_on_artigo_user_store
    rename_column :universidade_feedbacks, :artigo_id, :conteudo_id
    add_index     :universidade_feedbacks, [:conteudo_id, :user_id, :store_id], unique: true, name: :index_universidade_feedbacks_on_conteudo_user_store

    # 8. Data migration: atualizar item_type em secao_itens
    execute "UPDATE universidade_secao_itens SET item_type = 'Universidade::Trilha'   WHERE item_type = 'Universidade::Curso'"
    execute "UPDATE universidade_secao_itens SET item_type = 'Universidade::Conteudo' WHERE item_type = 'Universidade::Artigo'"

    # 9. Re-adicionar FK constraints
    add_foreign_key :universidade_modulos,    :universidade_trilhas,   column: :trilha_id,   on_delete: :nullify
    add_foreign_key :universidade_conteudos,  :universidade_modulos,   column: :modulo_id,   on_delete: :nullify
    add_foreign_key :universidade_conteudos,  :universidade_trilhas,   column: :trilha_id,   on_delete: :nullify
    add_foreign_key :universidade_progressos, :universidade_conteudos, column: :conteudo_id, on_delete: :cascade
    add_foreign_key :universidade_progressos, :universidade_trilhas,   column: :trilha_id,   on_delete: :cascade
    add_foreign_key :universidade_feedbacks,  :universidade_conteudos, column: :conteudo_id, on_delete: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
