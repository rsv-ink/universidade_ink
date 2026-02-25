module Universidade
  class ApplicationController < ActionController::Base
    helper_method :current_lojista_id

    def current_lojista_id
      Universidade.current_lojista_id(self)
    end
  end
end
