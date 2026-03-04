module Universidade
  class ApplicationController < ActionController::Base
    include SeoMeta

    helper_method :universidade_current_user

    def universidade_current_user
      Universidade.current_user(self)
    end
  end
end