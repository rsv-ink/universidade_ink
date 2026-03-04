module Universidade
  module SeoHelper
    # Retorna o título da página com fallback para "Universidade"
    def page_title(title = nil)
      base_title = "Universidade"
      if title.present?
        "#{title} | #{base_title}"
      else
        @page_title.present? ? "#{@page_title} | #{base_title}" : base_title
      end
    end

    # Retorna a meta tag keywords
    def meta_keywords(keywords = nil)
      kw = keywords || @page_keywords
      return nil if kw.blank?
      tag.meta(name: "keywords", content: Array(kw).join(", "))
    end

    # Retorna a meta tag description
    def meta_description(description = nil)
      desc = description || @page_description || "Plataforma de aprendizado com trilhas, cursos e conteúdos educacionais"
      tag.meta(name: "description", content: truncate_description(desc))
    end

    # Retorna a URL canônica da página
    def canonical_tag(url = nil)
      canonical_url = url || @canonical_url || request.original_url
      tag.link(rel: "canonical", href: canonical_url)
    end

    # Retorna as Open Graph meta tags
    def og_tags(options = {})
      og_title = options[:title] || @page_title || "Universidade"
      og_description = options[:description] || @page_description || "Plataforma de aprendizado"
      og_image = options[:image] || @page_image
      og_type = options[:type] || @page_type || "website"
      og_url = options[:url] || @canonical_url || request.original_url

      tags = []
      tags << tag.meta(property: "og:title", content: og_title)
      tags << tag.meta(property: "og:description", content: truncate_description(og_description))
      tags << tag.meta(property: "og:type", content: og_type)
      tags << tag.meta(property: "og:url", content: og_url)
      tags << tag.meta(property: "og:image", content: absolute_image_url(og_image)) if og_image.present?
      
      safe_join(tags, "\n")
    end

    # Retorna as Twitter Card meta tags
    def twitter_card_tags(options = {})
      twitter_title = options[:title] || @page_title || "Universidade"
      twitter_description = options[:description] || @page_description || "Plataforma de aprendizado"
      twitter_image = options[:image] || @page_image

      tags = []
      tags << tag.meta(name: "twitter:card", content: "summary_large_image")
      tags << tag.meta(name: "twitter:title", content: twitter_title)
      tags << tag.meta(name: "twitter:description", content: truncate_description(twitter_description))
      tags << tag.meta(name: "twitter:image", content: absolute_image_url(twitter_image)) if twitter_image.present?
      
      safe_join(tags, "\n")
    end

    # Retorna structured data JSON-LD para Article
    def json_ld_article(article)
      return nil unless article

      data = {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": article.titulo,
        "description": extract_description_from_body(article.corpo),
        "datePublished": article.created_at&.iso8601,
        "dateModified": article.updated_at&.iso8601
      }

      data["image"] = absolute_image_url(extract_first_image_from_body(article.corpo)) if extract_first_image_from_body(article.corpo)
      data["timeRequired"] = "PT#{article.tempo_estimado_minutos}M" if article.respond_to?(:tempo_estimado_minutos) && article.tempo_estimado_minutos.present?

      tag.script(data.to_json.html_safe, type: "application/ld+json")
    end

    # Retorna structured data JSON-LD para Course
    def json_ld_course(course)
      return nil unless course

      data = {
        "@context": "https://schema.org",
        "@type": "Course",
        "name": course.nome,
        "description": course.descricao || "Trilha de aprendizado",
        "provider": {
          "@type": "Organization",
          "name": "Universidade"
        }
      }

      data["image"] = absolute_image_url(course.imagem) if course.imagem.present?

      if course.respond_to?(:tags) && course.tags.any?
        data["keywords"] = course.tags.map(&:nome).join(", ")
      end

      tag.script(data.to_json.html_safe, type: "application/ld+json")
    end

    # Retorna structured data JSON-LD para BreadcrumbList
    def json_ld_breadcrumbs(items)
      return nil if items.blank?

      list_items = items.map.with_index(1) do |item, index|
        {
          "@type": "ListItem",
          "position": index,
          "name": item[:name],
          "item": item[:url]
        }
      end

      data = {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": list_items
      }

      tag.script(data.to_json.html_safe, type: "application/ld+json")
    end

    private

    # Trunca a descrição para 160 caracteres (limite recomendado para SEO)
    def truncate_description(text)
      return "" if text.blank?
      text.gsub(/<[^>]*>/, "").squish.truncate(160, separator: " ", omission: "...")
    end

    # Extrai a descrição do corpo de um artigo (primeiros 160 chars de texto)
    def extract_description_from_body(corpo)
      return "" if corpo.blank?

      blocks = begin
        parsed = JSON.parse(corpo)
        parsed.is_a?(Array) ? parsed : []
      rescue JSON::ParserError
        []
      end

      # Busca pelo primeiro bloco de texto
      text_block = blocks.find { |b| b["type"] == "texto" }
      if text_block && text_block["data"] && text_block["data"]["html"]
        return text_block["data"]["html"]
      end

      # Fallback para qualquer bloco com texto
      any_text = blocks.find { |b| b["data"] && b["data"]["text"] }
      any_text&.dig("data", "text") || ""
    end

    # Extrai a primeira imagem do corpo de um artigo
    def extract_first_image_from_body(corpo)
      return nil if corpo.blank?

      blocks = begin
        parsed = JSON.parse(corpo)
        parsed.is_a?(Array) ? parsed : []
      rescue JSON::ParserError
        []
      end

      image_block = blocks.find { |b| b["type"] == "imagem" }
      image_block&.dig("data", "url")
    end

    # Converte uma imagem para URL absoluta
    def absolute_image_url(image)
      return nil if image.blank?

      # Se já é uma URL completa, retorna
      return image if image.is_a?(String) && image.start_with?("http")

      # Se é um objeto Active Storage
      if image.respond_to?(:url)
        begin
          url = image.url
          return url if url.start_with?("http")
          return "#{request.protocol}#{request.host_with_port}#{url}"
        rescue => e
          Rails.logger.error("Erro ao gerar URL da imagem: #{e.message}")
          return nil
        end
      end

      # Se é um path relativo
      if image.is_a?(String)
        return "#{request.protocol}#{request.host_with_port}#{image}" unless image.start_with?("http")
      end

      nil
    end
  end
end
