module Universidade
  module Admin
    class SidebarItemsController < BaseController
      before_action :set_sidebar_item, only: %i[edit update destroy toggle_visivel]

      def index
        @sidebar_items = SidebarItem.ordenado
      end

      def new
        @sidebar_item = SidebarItem.new(visivel: true, tipo: "link")
        respond_to do |format|
          format.html { redirect_to admin_sidebar_items_path }
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "modal-content",
              partial: "universidade/admin/sidebar_items/form",
              locals: { sidebar_item: @sidebar_item, url: admin_sidebar_items_path }
            )
          end
        end
      end

      def create
        @sidebar_item = SidebarItem.new(sidebar_item_params)
        
        if @sidebar_item.save
          respond_to do |format|
            format.turbo_stream do
              streams = [
                turbo_stream.update("modal-content", ""),
                turbo_stream.prepend("sidebar_items_lista", 
                  partial: "universidade/admin/sidebar_items/sidebar_item",
                  locals: { sidebar_item: @sidebar_item }
                )
              ]
              # Remove empty state se existir
              if SidebarItem.count == 1
                streams << turbo_stream.remove("sidebar_items_empty_state")
              end
              render turbo_stream: streams
            end
            format.html { redirect_to admin_sidebar_items_path, notice: "Item criado com sucesso." }
          end
        else
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                "modal-content",
                partial: "universidade/admin/sidebar_items/form",
                locals: { sidebar_item: @sidebar_item, url: admin_sidebar_items_path }
              ), status: :unprocessable_entity
            end
            format.html { render :new, status: :unprocessable_entity }
          end
        end
      end

      def edit
        respond_to do |format|
          format.html { redirect_to admin_sidebar_items_path }
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "modal-content",
              partial: "universidade/admin/sidebar_items/form",
              locals: { sidebar_item: @sidebar_item, url: admin_sidebar_item_path(@sidebar_item) }
            )
          end
        end
      end

      def update
        if @sidebar_item.update(sidebar_item_params)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: [
                turbo_stream.update("modal-content", ""),
                turbo_stream.replace(
                  "sidebar_item_#{@sidebar_item.id}",
                  partial: "universidade/admin/sidebar_items/sidebar_item",
                  locals: { sidebar_item: @sidebar_item }
                )
              ]
            end
            format.html { redirect_to admin_sidebar_items_path, notice: "Item atualizado com sucesso." }
          end
        else
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                "modal-content",
                partial: "universidade/admin/sidebar_items/form",
                locals: { sidebar_item: @sidebar_item, url: admin_sidebar_item_path(@sidebar_item) }
              ), status: :unprocessable_entity
            end
            format.html { render :edit, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        nome = @sidebar_item.nome
        @sidebar_item.destroy
        
        respond_to do |format|
          format.turbo_stream do
            streams = [turbo_stream.remove("sidebar_item_#{@sidebar_item.id}")]
            # Adiciona empty state se não houver mais itens
            if SidebarItem.count == 0
              streams << turbo_stream.update(
                "sidebar_items_lista",
                partial: "universidade/admin/sidebar_items/empty_state"
              )
            end
            render turbo_stream: streams
          end
          format.html { redirect_to admin_sidebar_items_path, notice: "\"#{nome}\" excluído com sucesso." }
        end
      end

      def toggle_visivel
        @sidebar_item.update!(visivel: !@sidebar_item.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "sidebar_item_#{@sidebar_item.id}",
              partial: "universidade/admin/sidebar_items/sidebar_item",
              locals: { sidebar_item: @sidebar_item }
            )
          end
          format.html { redirect_to admin_sidebar_items_path }
        end
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        SidebarItem.transaction do
          ids.each_with_index { |id, i| SidebarItem.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      private

      def set_sidebar_item
        @sidebar_item = SidebarItem.find(params[:id])
      end

      def sidebar_item_params
        params.require(:sidebar_item).permit(:nome, :icone, :url, :tipo, :visivel)
      end
    end
  end
end
