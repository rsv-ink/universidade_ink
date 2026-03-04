module Universidade
  class ApplicationController < ActionController::Base
    include SeoMeta

    helper_method :universidade_current_user

    before_action :authenticate_universidade!

    def universidade_current_user
      Universidade.current_user(self)
    end
  end
end