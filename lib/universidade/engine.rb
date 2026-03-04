module Universidade
  class Engine < ::Rails::Engine
    isolate_namespace Universidade

    # Inflexão portuguesa: secao → secoes (Rails usa inglês por padrão)
    initializer "universidade.inflections" do
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.irregular "secao", "secoes"
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Add engine's JavaScript path to asset pipeline FIRST
    initializer "universidade.assets", before: :set_autoload_paths do |app|
      # Adiciona o caminho JavaScript ao asset pipeline
      app.config.assets.paths << root.join("app/javascript").to_s
      
      # Precompila os assets da engine
      app.config.assets.precompile += %w[
        universidade_manifest.js
        universidade/application.css
        universidade/application.js
        universidade/controllers/index.js
        universidade/**/*.js
      ]
    end

    # Configure importmap paths when the host app uses importmap-rails.
    initializer "universidade.importmap", before: "importmap" do |app|
      next unless app.config.respond_to?(:importmap) && app.config.importmap

      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
    end
  end
end
