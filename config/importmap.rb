# Pin npm packages from CDN - estas dependências são carregadas em modo standalone
pin "@hotwired/turbo-rails", to: "https://cdn.jsdelivr.net/npm/@hotwired/turbo-rails@8.0.12/+esm", preload: true
pin "@hotwired/stimulus", to: "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Engine JavaScript entry point for standalone mode
pin "universidade/application", to: "universidade/application.js", preload: true
pin "universidade/controllers", to: "universidade/controllers/index.js"

# Individual controller files
pin "universidade/controllers/editor_controller", to: "universidade/controllers/editor_controller.js"
pin "universidade/controllers/blocks_editor_controller", to: "universidade/controllers/blocks_editor_controller.js"
pin "universidade/controllers/accordion_controller", to: "universidade/controllers/accordion_controller.js"
pin "universidade/controllers/modal_controller", to: "universidade/controllers/modal_controller.js"
pin "universidade/controllers/modal_link_controller", to: "universidade/controllers/modal_link_controller.js"
pin "universidade/controllers/sortable_controller", to: "universidade/controllers/sortable_controller.js"
pin "universidade/controllers/hierarchical_sortable_controller", to: "universidade/controllers/hierarchical_sortable_controller.js"
pin "universidade/controllers/sidebar_controller", to: "universidade/controllers/sidebar_controller.js"
pin "universidade/controllers/sidebar_toggle_controller", to: "universidade/controllers/sidebar_toggle_controller.js"
pin "universidade/controllers/sidebar_spacing_controller", to: "universidade/controllers/sidebar_spacing_controller.js"
pin "universidade/controllers/sidebar_item_form_controller", to: "universidade/controllers/sidebar_item_form_controller.js"
pin "universidade/controllers/mobile_sidebar_controller", to: "universidade/controllers/mobile_sidebar_controller.js"
pin "universidade/controllers/carrossel_controller", to: "universidade/controllers/carrossel_controller.js"
pin "universidade/controllers/secao_form_controller", to: "universidade/controllers/secao_form_controller.js"
pin "universidade/controllers/trilha_modulo_selector_controller", to: "universidade/controllers/trilha_modulo_selector_controller.js"
pin "universidade/controllers/trilhas_manager_controller", to: "universidade/controllers/trilhas_manager_controller.js"
pin "universidade/controllers/analytics_controller", to: "universidade/controllers/analytics_controller.js"
pin "universidade/controllers/user_menu_controller", to: "universidade/controllers/user_menu_controller.js"
pin "universidade/controllers/taxonomy_suggestions_controller", to: "universidade/controllers/taxonomy_suggestions_controller.js"
pin "universidade/controllers/tags_selector_controller", to: "universidade/controllers/tags_selector_controller.js"
pin "universidade/controllers/categoria_selector_controller", to: "universidade/controllers/categoria_selector_controller.js"
pin "universidade/controllers/categoria_creator_controller", to: "universidade/controllers/categoria_creator_controller.js"
pin "universidade/controllers/busca_rapida_controller", to: "universidade/controllers/busca_rapida_controller.js"

# Sortable.js — drag & drop
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/+esm"

