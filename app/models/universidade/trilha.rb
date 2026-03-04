module Universidade
  class Trilha < ApplicationRecord
    include ImageProcessor
    
    self.table_name = "universidade_trilhas"

    has_one_attached :imagem
    has_many :modulos, class_name: "Universidade::Modulo", foreign_key: :trilha_id, dependent: :nullify
    
    # Relação muitos-para-muitos com conteúdos através de trilha_conteudos
    has_many :trilha_conteudos, class_name: "Universidade::TrilhaConteudo", foreign_key: :trilha_id, dependent: :destroy
    has_many :conteudos, through: :trilha_conteudos, class_name: "Universidade::Conteudo"
    
    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :trilha_id, dependent: :destroy

    has_many :trilha_tags, class_name: "Universidade::TrilhaTag", foreign_key: :trilha_id, dependent: :destroy
    has_many :tags, through: :trilha_tags, class_name: "Universidade::Tag"

    validates :nome, presence: true
    validates :user_id, presence: true
    validates :store_id, presence: true

    attribute :rascunho, :boolean, default: false

    scope :visivel, -> { where(visivel: true, rascunho: false) }
    scope :buscar, ->(q) {
      left_joins(:tags)
        .where(
          "lower(universidade_trilhas.nome) LIKE lower(:q) OR lower(COALESCE(universidade_trilhas.descricao,'')) LIKE lower(:q) OR lower(COALESCE(universidade_tags.nome,'')) LIKE lower(:q)",
          q: "%#{q}%"
        )
        .distinct
    }

    def publicado?
      !rascunho? && visivel?
    end

    def despublicado?
      !rascunho? && !visivel?
    end

    # Atributo virtual para o formulário: tags como texto separado por vírgula.
    def tags_text
      tags.map(&:nome).join(", ")
    end

    # Slug humanizado para URLs amigáveis (ex: "1-ruby-on-rails").
    # Rails extrai o ID automaticamente via to_i no finder.
    def to_param
      "#{id}-#{nome.parameterize}"
    end

    # Retorna a fração de conteúdos visíveis concluídos pelo usuário em toda a trilha (0.0 a 1.0).
    # Considera conteúdos vinculados à trilha através da tabela de junção.
    def progresso_lojista(user_id, store_id)
      return 0.0 unless user_id && store_id

      # Todos os conteúdos visíveis vinculados a esta trilha
      conteudo_ids = trilha_conteudos.joins(:conteudo).where(universidade_conteudos: { visivel: true }).pluck(:conteudo_id).uniq
      total = conteudo_ids.size
      return 0.0 if total.zero?

      concluidos = Progresso
        .where(conteudo_id: conteudo_ids, user_id: user_id, store_id: store_id)
        .where.not(concluido_em: nil)
        .count

      concluidos.to_f / total
    end

    # Retorna true se todos os conteúdos visíveis da trilha foram concluídos pelo usuário.
    def concluida?(user_id, store_id)
      progresso_lojista(user_id, store_id) == 1.0
    end

    # Retorna lista flat ordenada de todos os conteúdos visíveis da trilha
    # Os conteúdos podem estar agrupados por módulos ou não
    def conteudos_ordenados
      trilha_conteudos
        .joins(:conteudo)
        .where(universidade_conteudos: { visivel: true })
        .order(:posicao)
        .includes(:conteudo)
        .map(&:conteudo)
    end

    # Retorna conteúdos que estão vinculados a outras trilhas além desta
    def conteudos_compartilhados
      conteudos.select { |c| c.trilhas_count > 1 }
    end

    # Retorna se a trilha possui conteúdos compartilhados
    def tem_conteudos_compartilhados?
      conteudos_compartilhados.any?
    end

    # Retorna se a trilha possui módulos
    def tem_modulos?
      modulos.exists?
    end

    # Exclui a trilha e tudo que está dentro dela
    # Opções:
    # - excluir_conteudos: true = exclui conteúdos que pertencem apenas a esta trilha
    #                      false = mantém todos os conteúdos (apenas desvincula)
    def excluir_com_opcoes(excluir_conteudos: false)
      transaction do
        if excluir_conteudos
          # Exclui conteúdos que estão apenas nesta trilha
          conteudos_exclusivos = conteudos.select { |c| c.trilhas_count == 1 }
          conteudos_exclusivos.each(&:destroy)
        end
        
        # A exclusão da trilha remove automaticamente:
        # - trilha_conteudos (dependent: :destroy)
        # - progressos (dependent: :destroy)
        # - e nullifica modulos (dependent: :nullify)
        destroy
      end
    end
  end
end
