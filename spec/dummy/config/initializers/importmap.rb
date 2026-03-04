# Merge engine importmap into dummy app
# This allows the dummy app to load engine controllers via importmap
Rails.application.config.after_initialize do
  # Merge engine's importmap into the app's importmap
  if defined?(Universidade::Engine) && Rails.application.importmap
    engine_importmap_path = Universidade::Engine.root.join("config/importmap.rb")
    Rails.application.importmap.instance_eval(File.read(engine_importmap_path)) if File.exist?(engine_importmap_path)
  end
end
