module Universidade
  class Modulo < ApplicationRecord
    self.table_name = "universidade_modulos"

    belongs_to :trilha, class_name: "Universidade::Trilha", optional: true

    # Conteúdos são vinculados através da trilha_conteudos com modulo_id
    has_many :trilha_conteudos, class_name: "Universidade::TrilhaConteudo", foreign_key: :modulo_id, dependent: :nullify
    has_many :conteudos, through: :trilha_conteudos, class_name: "Universidade::Conteudo"

    validates :nome, presence: true
    validates :user_id, presence: true
    validates :store_id, presence: true

    attribute :rascunho, :boolean, default: false

    scope :visivel, -> { where(visivel: true, rascunho: false) }
    scope :buscar, ->(q) { where("lower(nome) LIKE lower(:q) OR lower(COALESCE(descricao,'')) LIKE lower(:q)", q: "%#{q}%") }

    def publicado?
      !rascunho? && visivel?
    end

    def despublicado?
      !rascunho? && !visivel?
    end

    # Retorna a fração de conteúdos concluídos pelo usuário (0.0 a 1.0).
    # Conta apenas conteúdos visíveis deste módulo.
    def progresso(user_id, store_id)
      return 0.0 unless user_id && store_id
      
      # Get conteudos through trilha_conteudos for this module
      conteudo_ids = trilha_conteudos.joins(:conteudo).where(universidade_conteudos: { visivel: true }).pluck(:conteudo_id)
      total = conteudo_ids.size
      return 0.0 if total.zero?

      concluidos = Progresso
        .where(conteudo_id: conteudo_ids, user_id: user_id, store_id: store_id)
        .where.not(concluido_em: nil)
        .count

      concluidos.to_f / total
    end

    # Retorna conteúdos que estão vinculados a outras trilhas além da trilha deste módulo
    def conteudos_compartilhados
      conteudos.select { |c| c.trilhas_count > 1 }
    end

    # Retorna se o módulo possui conteúdos compartilhados
    def tem_conteudos_compartilhados?
      conteudos_compartilhados.any?
    end

    # Exclui o módulo e opcionalmente os conteúdos
    # Opções:
    # - excluir_conteudos: true = exclui conteúdos que pertencem apenas a esta trilha
    #                      false = mantém todos os conteúdos (apenas desvincula do módulo)
    def excluir_com_opcoes(excluir_conteudos: false)
      transaction do
        if excluir_conteudos
          # Exclui conteúdos que estão apenas nesta trilha (a trilha do módulo)
          if trilha
            conteudos_do_modulo = conteudos.to_a
            conteudos_do_modulo.each do |conteudo|
              # Se o conteúdo só está nesta trilha, pode excluir
              if conteudo.trilhas_count == 1
                conteudo.destroy
              end
            end
          else
            # Módulo sem trilha - exclui todos os conteúdos vinculados apenas a ele
            conteudos.each { |c| c.destroy if c.trilhas_count == 1 }
          end
        end
        
        # A exclusão do módulo nullifica trilha_conteudos.modulo_id (dependent: :nullify)
        destroy
      end
    end
  end
end
