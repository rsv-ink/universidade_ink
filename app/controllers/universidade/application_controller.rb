module Universidade
  class ApplicationController < ActionController::Base
    include SeoMeta

    helper_method :universidade_current_user

    before_action :authenticate_universidade!

    def universidade_current_user
      Universidade.current_user(self)
    end

    private

    def authenticate_universidade!
      return if user_in_universidade?(universidade_current_user)

      redirect_to main_app.root_path, alert: "Acesso negado"
    end

    def user_in_universidade?(user)
      return false unless user
      return user.in_universidade? if user.respond_to?(:in_universidade?)

      false
    end
  end
end
