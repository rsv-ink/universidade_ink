# frozen_string_literal: true

module Universidade
  module Admin
    class UploadsController < BaseController
      # POST /admin/rich_image_upload
      def image
        file = params[:image]
        return render_error("Arquivo não enviado") if file.blank?

        # Validar tipo de arquivo
        unless file.content_type&.start_with?("image/")
          return render_error("O arquivo deve ser uma imagem")
        end

        # Processar e converter para WebP
        blob = process_and_upload_image(file)

        # Retornar URL e metadados
        render json: {
          url: main_app.rails_blob_url(blob),
          size_kb: blob.metadata["size_kb"],
          width: blob.metadata["width"],
          height: blob.metadata["height"],
          filename: blob.filename.to_s
        }
      rescue StandardError => e
        render_error(e.message)
      end

      private

      def render_error(message)
        render json: { error: message }, status: :unprocessable_entity
      end

      def process_and_upload_image(file)
        require "image_processing/vips"
        require "vips"

        # Criar arquivo temporário para processar
        temp_file = Tempfile.new(["upload", File.extname(file.original_filename)])
        temp_file.binmode
        temp_file.write(file.read)
        temp_file.rewind

        # Processar e converter para WebP
        processed = ImageProcessing::Vips
          .source(temp_file.path)
          .convert("webp")
          .saver(quality: 85, strip: true)
          .call

        # Extrair metadados
        image = Vips::Image.new_from_file(processed.path)
        processed_size = File.size(processed.path)
        size_kb = (processed_size / 1024.0).round(2)

        # Criar nome de arquivo WebP
        original_basename = File.basename(file.original_filename, ".*")
        webp_filename = "#{original_basename}.webp"

        # Criar e fazer upload do blob
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(processed.path),
          filename: webp_filename,
          content_type: "image/webp",
          metadata: {
            size_kb: size_kb,
            original_filename: file.original_filename,
            original_content_type: file.content_type,
            width: image.width,
            height: image.height,
            converted_to_webp: true
          }
        )

        blob
      ensure
        # Limpar arquivos temporários
        temp_file&.close
        temp_file&.unlink
        File.unlink(processed.path) if processed && File.exist?(processed.path)
      end
    end
  end
end
