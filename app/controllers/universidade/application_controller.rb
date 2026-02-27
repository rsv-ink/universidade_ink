module Universidade
  class ApplicationController < ActionController::Base
    helper_method :current_user_id, :current_store_id

    def current_user_id
      Universidade.current_user_id(self)
    end

    def current_store_id
      Universidade.current_store_id(self)
    end
  end
end
