require_relative "lib/universidade/version"

Gem::Specification.new do |spec|
  spec.name        = "universidade"
  spec.version     = Universidade::VERSION
  spec.authors     = ["Ink Team"]
  spec.email       = ["dev@ink.com"]
  spec.homepage    = "https://github.com/ink/universidade"
  spec.summary     = "Sistema de universidade/learning management para Rails"
  spec.description = "Engine Rails para criação de plataforma de ensino com trilhas, módulos, conteúdos, taxonomia e rastreamento de progresso."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/ink"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ink/universidade"
  spec.metadata["changelog_uri"] = "https://github.com/ink/universidade/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/ink/universidade/issues"
  spec.metadata["documentation_uri"] = "https://github.com/ink/universidade/blob/main/README.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8.7"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "pg"
end
