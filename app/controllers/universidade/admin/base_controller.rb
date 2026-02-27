module Universidade
  module Admin
    class BaseController < ApplicationController
      layout "universidade/admin"
      before_action :authenticate_admin!

      private

      def authenticate_admin!
        return if admin_user?(Universidade.current_user(self))

        redirect_to main_app.root_path, alert: "Acesso negado"
      end

      def admin_user?(user)
        return false unless user
        return user.is_admin? if user.respond_to?(:is_admin?)

        false
      end
    end
  end
end
