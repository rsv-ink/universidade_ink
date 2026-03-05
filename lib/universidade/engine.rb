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

    initializer "universidade.assets", before: :set_autoload_paths do |app|
      app.config.assets.paths << root.join("app/assets/builds").to_s

      app.config.assets.precompile += %w[ universidade_manifest.js ]
    end
  end
end
