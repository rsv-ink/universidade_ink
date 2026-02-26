module Universidade
  module EditorjsHelper
    # Renderiza o conteúdo de um artigo (campo `corpo`) para HTML.
    # Suporta o novo formato JSON de blocos e legado HTML puro.
    def render_blocks(corpo)
      return "".html_safe if corpo.blank?

      blocks = begin
        parsed = JSON.parse(corpo)
        parsed.is_a?(Array) ? parsed : nil
      rescue JSON::ParserError
        nil
      end

      if blocks
        html = blocks.map { |b| render_one_block(b) }.compact.join("\n")
        content_tag(:div, html.html_safe, class: "blocks-render")
      else
        # Legado: HTML bruto armazenado diretamente
        content_tag(:div, corpo.html_safe, class: "editor-content")
      end
    end

    private

    def render_one_block(block)
      type = block["type"].to_s
      data = block["data"] || {}

      case type
      when "titulo"
        text  = h(data["text"].to_s)
        return nil if text.blank?
        level = [1, 2, 3, 4].include?(data["level"].to_i) ? data["level"].to_i : 2
        "<h#{level} class=\"block-titulo\">#{text}</h#{level}>"

      when "texto"
        html = data["html"].to_s
        return nil if html.blank?
        "<div class=\"block-texto\">#{html}</div>"

      when "citacao"
        text    = data["text"].to_s
        caption = data["caption"].to_s
        return nil if text.blank?
        cite = caption.present? ? "<cite>#{h(caption)}</cite>" : ""
        "<blockquote class=\"block-citacao\">#{text}#{cite}</blockquote>"

      when "lista"
        items = Array(data["items"]).select(&:present?)
        return nil if items.empty?
        tag   = data["style"] == "ordered" ? "ol" : "ul"
        lis   = items.map { |item| "<li>#{h(item)}</li>" }.join
        "<#{tag} class=\"block-lista\">#{lis}</#{tag}>"

      when "codigo"
        code = data["code"].to_s
        return nil if code.blank?
        "<pre class=\"block-codigo\"><code>#{h(code)}</code></pre>"

      when "imagem"
        # Migrate old single-image format { url, alt } → new format
        data = if data["images"].nil? && data["url"].present?
          { "layout" => "galeria", "images" => [{ "url" => data["url"], "alt" => data["alt"].to_s }] }
        else
          data
        end

        images = Array(data["images"]).select { |img| img["url"].present? }
        return nil if images.empty?

        layout = data["layout"].to_s == "carrossel" ? "carrossel" : "galeria"

        if layout == "carrossel"
          _render_carrossel(images)
        else
          _render_galeria(images)
        end

      when "video"
        embed = data["embedUrl"].to_s.gsub("www.youtube.com/embed/", "www.youtube-nocookie.com/embed/")
        return nil if embed.blank?
        "<figure class=\"block-video\"><iframe src=\"#{h(embed)}\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen></iframe></figure>"

      when "divisor"
        "<hr class=\"block-divisor\" />"

      when "destaque"
        text  = data["text"].to_s
        return nil if text.blank?
        color = data["color"].to_s.match?(/\A#[0-9a-fA-F]{3,6}\z/) ? data["color"] : "#fef9c3"
        "<div class=\"block-destaque\" style=\"background-color:#{color}\">#{text}</div>"

      else
        nil
      end
    end

    def _render_carrossel(images)
      slides = images.map { |img|
        "<div class=\"carrossel-slide\"><img src=\"#{h(img["url"])}\" alt=\"#{h(img["alt"].to_s)}\" loading=\"lazy\" /></div>"
      }.join

      dots = images.each_with_index.map { |_, i|
        active = i == 0 ? " active" : ""
        "<button class=\"carrossel-dot#{active}\" data-carrossel-target=\"dot\" data-index=\"#{i}\" data-action=\"click->carrossel#dot\"></button>"
      }.join

      nav = images.size > 1 ? <<~HTML
        <button class="carrossel-btn carrossel-btn-prev" data-action="click->carrossel#prev">&#8249;</button>
        <button class="carrossel-btn carrossel-btn-next" data-action="click->carrossel#next">&#8250;</button>
        <div class="carrossel-dots">#{dots}</div>
      HTML
      : ""

      <<~HTML
        <figure class="block-imagem block-imagem--carrossel" data-controller="carrossel">
          <div class="carrossel-viewport">
            <div class="carrossel-track" data-carrossel-target="track">#{slides}</div>
          </div>
          #{nav}
        </figure>
      HTML
    end

    def _render_galeria(images)
      imgs = images.map { |img|
        "<img src=\"#{h(img["url"])}\" alt=\"#{h(img["alt"].to_s)}\" loading=\"lazy\" />"
      }.join

      <<~HTML
        <figure class="block-imagem block-imagem--galeria">
          <div class="galeria-grid">#{imgs}</div>
        </figure>
      HTML
    end
  end
end
