# frozen_string_literal: true

module ImageProcessor
  extend ActiveSupport::Concern

  included do
    # Callbacks para processar imagens anexadas
    after_save :process_attached_images, if: -> { saved_change_to_attribute?(:id) || attachments_changed? }
  end

  private

  def attachments_changed?
    # Verifica se há mudanças em anexos do Active Storage
    self.class.reflect_on_all_attachments.any? do |attachment|
      public_send(attachment.name).attached? && public_send(attachment.name).attachment.new_record?
    end
  rescue StandardError
    false
  end

  def process_attached_images
    # Processa anexos únicos (has_one_attached)
    self.class.reflect_on_all_attachments.each do |attachment|
      next unless attachment.macro == :has_one_attached

      process_single_attachment(public_send(attachment.name))
    end

    # Processa anexos múltiplos (has_many_attached)
    self.class.reflect_on_all_attachments.each do |attachment|
      next unless attachment.macro == :has_many_attached

      public_send(attachment.name).each do |attached_file|
        process_single_attachment(attached_file)
      end
    end
  end

  def process_single_attachment(attached_file)
    return unless attached_file.attached?
    return unless attached_file.blob.present?
    return unless attached_file.blob.content_type&.start_with?("image/")
    return if attached_file.blob.filename.to_s.end_with?(".webp")

    # Converte para WebP e atualiza metadados
    convert_to_webp(attached_file)
  rescue StandardError => e
    Rails.logger.error "Erro ao processar imagem #{attached_file.blob.filename}: #{e.message}"
  end

  def convert_to_webp(attached_file)
    require "image_processing/vips"

    blob = attached_file.blob
    original_size_kb = (blob.byte_size / 1024.0).round(2)

    # Download do arquivo original
    blob.open do |file|
      # Processar e converter para WebP
      processed = ImageProcessing::Vips
        .source(file)
        .convert("webp")
        .saver(quality: 85, strip: true)
        .call

      # Criar novo nome de arquivo com extensão .webp
      new_filename = blob.filename.to_s.sub(/\.(jpg|jpeg|png|gif)\z/i, ".webp")
      new_filename = "#{blob.filename.base}.webp" unless new_filename.end_with?(".webp")

      # Calcular tamanho do arquivo processado
      processed_size = File.size(processed.path)
      processed_size_kb = (processed_size / 1024.0).round(2)

      # Criar novo blob com a imagem WebP
      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(processed.path),
        filename: new_filename,
        content_type: "image/webp",
        metadata: blob.metadata.merge(
          size_kb: processed_size_kb,
          original_size_kb: original_size_kb,
          original_format: blob.content_type,
          converted_to_webp: true,
          width: processed_metadata(processed)[:width],
          height: processed_metadata(processed)[:height]
        )
      )

      # Substituir o blob antigo pelo novo
      attached_file.attachment.update(blob: new_blob)
      
      # Remover o blob antigo
      blob.purge_later unless blob.destroyed?

      # Limpar arquivo temporário
      File.unlink(processed.path) if File.exist?(processed.path)
    end
  end

  def processed_metadata(processed_file)
    require "vips"
    
    image = Vips::Image.new_from_file(processed_file.path)
    {
      width: image.width,
      height: image.height
    }
  rescue StandardError => e
    Rails.logger.warn "Não foi possível extrair metadados da imagem: #{e.message}"
    { width: nil, height: nil }
  end
end
