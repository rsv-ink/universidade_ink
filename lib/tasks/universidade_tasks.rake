# frozen_string_literal: true

namespace :universidade do
  namespace :version do
    desc "Mostra a versão atual da gem"
    task :show do
      require_relative "../universidade/version"
      puts "\n╔═══════════════════════════════════════════╗"
      puts "║   Universidade Gem Version Info           ║"
      puts "╠═══════════════════════════════════════════╣"
      puts "║ Version:      #{Universidade::VERSION.ljust(27)} ║"
      puts "║ Semver:       #{Universidade::Version.semver.ljust(27)} ║"
      puts "╚═══════════════════════════════════════════╝\n"
    end

    desc "Incrementa a versão PATCH (0.1.0 -> 0.1.1)"
    task :patch do
      bump_version(:patch)
    end

    desc "Incrementa a versão MINOR (0.1.0 -> 0.2.0)"
    task :minor do
      bump_version(:minor)
    end

    desc "Incrementa a versão MAJOR (0.1.0 -> 1.0.0)"
    task :major do
      bump_version(:major)
    end

    def bump_version(type)
      require_relative "../universidade/version"
      
      old_version = Universidade::VERSION
      major = Universidade::Version::MAJOR
      minor = Universidade::Version::MINOR
      patch = Universidade::Version::PATCH

      case type
      when :major
        major += 1
        minor = 0
        patch = 0
      when :minor
        minor += 1
        patch = 0
      when :patch
        patch += 1
      end

      new_version = "#{major}.#{minor}.#{patch}"
      
      # Atualiza o arquivo version.rb
      version_file = File.expand_path("../universidade/version.rb", __dir__)
      content = File.read(version_file)
      
      # Atualiza VERSION
      content.gsub!(/VERSION = "#{Regexp.escape(old_version)}"/, "VERSION = \"#{new_version}\"")
      
      # Atualiza constantes
      content.gsub!(/MAJOR = \d+/, "MAJOR = #{major}")
      content.gsub!(/MINOR = \d+/, "MINOR = #{minor}")
      content.gsub!(/PATCH = \d+/, "PATCH = #{patch}")
      
      File.write(version_file, content)
      
      puts "\n✓ Versão atualizada: #{old_version} -> #{new_version}"
      puts "  Não esqueça de:"
      puts "  1. Atualizar o CHANGELOG.md"
      puts "  2. Commitar as mudanças: git add . && git commit -m 'Bump version to #{new_version}'"
      puts "  3. Criar uma tag: git tag v#{new_version}"
      puts "  4. Push: git push && git push --tags\n"
    end
  end

  desc "Mostra informações da gem"
  task :info do
    require_relative "../universidade/version"
    require_relative "../universidade"
    
    puts "\n╔═══════════════════════════════════════════════════════════╗"
    puts "║              Universidade Gem Information                 ║"
    puts "╠═══════════════════════════════════════════════════════════╣"
    puts "║ Version:        #{Universidade::VERSION.ljust(39)} ║"
    puts "║ License:        MIT#{' ' * 36} ║"
    puts "║ Engine:         Mountable Rails Engine#{' ' * 18} ║"
    puts "╠═══════════════════════════════════════════════════════════╣"
    puts "║ Features:                                                 ║"
    puts "║  • Taxonomia (categorias e tags)                          ║"
    puts "║  • Trilhas, Módulos e Conteúdos                           ║"
    puts "║  • Sistema de Progresso                                   ║"
    puts "║  • Seções personalizáveis                                 ║"
    puts "║  • Multi-tenancy (user_id, store_id)                      ║"
    puts "║  • Turbo & Stimulus                                       ║"
    puts "╚═══════════════════════════════════════════════════════════╝\n"
  end

  desc "Valida a estrutura da gem"
  task :validate do
    errors = []
    warnings = []

    # Verifica arquivos essenciais
    required_files = %w[
      CHANGELOG.md
      README.md
      MIT-LICENSE
      lib/universidade.rb
      lib/universidade/version.rb
      lib/universidade/engine.rb
      universidade.gemspec
    ]

    required_files.each do |file|
      unless File.exist?(File.expand_path("../../#{file}", __dir__))
        errors << "Arquivo obrigatório ausente: #{file}"
      end
    end

    # Verifica CHANGELOG
    changelog = File.expand_path("../../CHANGELOG.md", __dir__)
    if File.exist?(changelog)
      content = File.read(changelog)
      unless content.include?(Universidade::VERSION)
        warnings << "CHANGELOG.md não contém a versão atual (#{Universidade::VERSION})"
      end
    end

    # Resultado
    puts "\n╔═══════════════════════════════════════════╗"
    puts "║        Validação da Gem                   ║"
    puts "╠═══════════════════════════════════════════╣"
    
    if errors.empty? && warnings.empty?
      puts "║ ✓ Todos os checks passaram!              ║"
      puts "╚═══════════════════════════════════════════╝\n"
    else
      if errors.any?
        puts "║ ✗ Erros encontrados:                      ║"
        errors.each { |e| puts "║   - #{e.ljust(39)} ║" }
      end
      
      if warnings.any?
        puts "║ ⚠ Avisos:                                 ║"
        warnings.each { |w| puts "║   - #{w.ljust(39)} ║" }
      end
      puts "╚═══════════════════════════════════════════╝\n"
      
      exit 1 if errors.any?
    end
  end
end
