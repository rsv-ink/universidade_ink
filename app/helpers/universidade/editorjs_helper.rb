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
        text = h(data["text"].to_s)
        return nil if text.blank?
        "<h2 class=\"block-titulo\">#{text}</h2>"

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

      when "tabela"
        rows = Array(data["rows"])
        return nil if rows.empty?
        header = rows.first.map { |c| "<th>#{h(c)}</th>" }.join
        body   = rows[1..].map { |row|
          cells = row.map { |c| "<td>#{h(c)}</td>" }.join
          "<tr>#{cells}</tr>"
        }.join
        "<table class=\"block-tabela\"><thead><tr>#{header}</tr></thead><tbody>#{body}</tbody></table>"

      when "imagem"
        url = data["url"].to_s
        return nil if url.blank?
        alt = h(data["alt"].to_s)
        "<figure class=\"block-imagem\"><img src=\"#{h(url)}\" alt=\"#{alt}\" /></figure>"

      when "video"
        embed = data["embedUrl"].to_s
        return nil if embed.blank?
        "<figure class=\"block-video\"><iframe src=\"#{h(embed)}\" allowfullscreen></iframe></figure>"

      else
        nil
      end
    end
  end
end
