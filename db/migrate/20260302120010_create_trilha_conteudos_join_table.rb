class CreateTrilhaConteudosJoinTable < ActiveRecord::Migration[7.2]
  def up
    # Criar tabela de join para relação muitos-para-muitos entre trilhas e conteúdos
    create_table :universidade_trilha_conteudos do |t|
      t.references :trilha, null: false, foreign_key: { to_table: :universidade_trilhas, on_delete: :cascade }
      t.references :conteudo, null: false, foreign_key: { to_table: :universidade_conteudos, on_delete: :cascade }
      t.references :modulo, null: true, foreign_key: { to_table: :universidade_modulos, on_delete: :nullify }
      t.integer :posicao, null: false, default: 0
      t.timestamps
    end

    # Índice para garantir que um conteúdo não seja adicionado duplicado na mesma trilha
    add_index :universidade_trilha_conteudos, [:trilha_id, :conteudo_id], unique: true,
              name: :index_trilha_conteudos_on_trilha_and_conteudo

    # Índice para ordenação
    add_index :universidade_trilha_conteudos, [:trilha_id, :posicao],
              name: :index_trilha_conteudos_on_trilha_and_posicao

    # Migrar dados existentes para a nova tabela
    # Conteúdos que pertencem diretamente a uma trilha (trilha_id não nulo)
    execute <<-SQL
      INSERT INTO universidade_trilha_conteudos (trilha_id, conteudo_id, modulo_id, posicao, created_at, updated_at)
      SELECT 
        trilha_id,
        id as conteudo_id,
        NULL as modulo_id,
        COALESCE(ordem, id) as posicao,
        created_at,
        updated_at
      FROM universidade_conteudos
      WHERE trilha_id IS NOT NULL
    SQL

    # Conteúdos que pertencem a um módulo (e indiretamente a uma trilha via módulo)
    execute <<-SQL
      INSERT INTO universidade_trilha_conteudos (trilha_id, conteudo_id, modulo_id, posicao, created_at, updated_at)
      SELECT 
        m.trilha_id,
        c.id as conteudo_id,
        c.modulo_id,
        COALESCE(c.ordem, c.id) as posicao,
        c.created_at,
        c.updated_at
      FROM universidade_conteudos c
      INNER JOIN universidade_modulos m ON m.id = c.modulo_id
      WHERE c.modulo_id IS NOT NULL AND m.trilha_id IS NOT NULL
    SQL

    # Remover as colunas antigas de relacionamento direto
    remove_foreign_key :universidade_conteudos, :universidade_trilhas if foreign_key_exists?(:universidade_conteudos, :universidade_trilhas)
    remove_foreign_key :universidade_conteudos, :universidade_modulos if foreign_key_exists?(:universidade_conteudos, :universidade_modulos)
    
    remove_index :universidade_conteudos, :trilha_id if index_exists?(:universidade_conteudos, :trilha_id)
    remove_index :universidade_conteudos, :modulo_id if index_exists?(:universidade_conteudos, :modulo_id)
    
    remove_column :universidade_conteudos, :trilha_id
    remove_column :universidade_conteudos, :modulo_id
  end

  def down
    # Adicionar de volta as colunas
    add_column :universidade_conteudos, :modulo_id, :bigint
    add_column :universidade_conteudos, :trilha_id, :bigint
    
    add_index :universidade_conteudos, :modulo_id
    add_index :universidade_conteudos, :trilha_id
    
    add_foreign_key :universidade_conteudos, :universidade_modulos, column: :modulo_id, on_delete: :nullify
    add_foreign_key :universidade_conteudos, :universidade_trilhas, column: :trilha_id, on_delete: :nullify

    # Migrar dados de volta (pega apenas a primeira ocorrência de cada conteúdo)
    execute <<-SQL
      UPDATE universidade_conteudos
      SET modulo_id = (
        SELECT modulo_id
        FROM universidade_trilha_conteudos
        WHERE conteudo_id = universidade_conteudos.id
        LIMIT 1
      ),
      trilha_id = (
        SELECT CASE WHEN modulo_id IS NULL THEN trilha_id ELSE NULL END
        FROM universidade_trilha_conteudos
        WHERE conteudo_id = universidade_conteudos.id
        LIMIT 1
      )
    SQL

    drop_table :universidade_trilha_conteudos
  end
end
