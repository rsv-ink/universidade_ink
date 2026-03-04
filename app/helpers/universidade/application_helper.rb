module Universidade
  module ApplicationHelper
    include Universidade::EditorjsHelper
    include Universidade::SeoHelper
    
    def user_initials(user)
      return "?" unless user
      
      first = user.try(:first_name) || user.try(:nome) || ""
      last = user.try(:last_name) || ""
      
      initials = "#{first.to_s.first}#{last.to_s.first}".upcase
      initials.presence || "?"
    end
  end
end
