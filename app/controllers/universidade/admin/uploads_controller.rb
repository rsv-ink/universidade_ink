# frozen_string_literal: true

module Universidade
  module Admin
    class UploadsController < BaseController
      # POST /admin/rich_image_upload
      def image
        file = params[:image]
        return render_error("Arquivo não enviado") if file.blank?

        blob = ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename: file.original_filename,
          content_type: file.content_type
        )

        render json: { url: main_app.rails_blob_url(blob) }
      rescue StandardError => e
        render_error(e.message)
      end

      private

      def render_error(message)
        render json: { error: message }, status: :unprocessable_entity
      end
    end
  end
end
