module SeoMeta
  extend ActiveSupport::Concern

  # Define as meta tags para a página
  def set_meta_tags(title: nil, description: nil, image: nil, type: "website", url: nil, keywords: nil)
    @page_title = title
    @page_description = description
    @page_image = image
    @page_type = type
    @canonical_url = url
    @page_keywords = keywords
  end

  # Define JSON-LD structured data
  def set_json_ld(data)
    @json_ld_data = data
  end
end
