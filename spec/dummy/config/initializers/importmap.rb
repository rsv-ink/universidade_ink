# Configure o importmap para servir arquivos JavaScript da engine
Rails.application.config.after_initialize do
  # Adiciona o caminho da engine ao asset path se não estiver presente
  engine_js_path = Universidade::Engine.root.join("app/javascript")
  
  unless Rails.application.config.assets.paths.include?(engine_js_path.to_s)
    Rails.application.config.assets.paths.unshift(engine_js_path.to_s)
  end
end
