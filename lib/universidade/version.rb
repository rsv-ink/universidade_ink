module Universidade
  VERSION = "0.1.4"
  
  # Informações sobre a versão
  module Version
    MAJOR = 0
    MINOR = 1
    PATCH = 4
    PRE   = nil
    
    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join(".")
    
    # Retorna informações completas da versão
    def self.to_s
      STRING
    end
    
    # Retorna a versão em formato semântico
    def self.semver
      "v#{STRING}"
    end
    
    # Retorna informações completas da gem
    def self.info
      {
        version: STRING,
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION
      }
    end
  end
end
