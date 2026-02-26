pin "application", to: "universidade/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Controllers da engine
pin "controllers", to: "universidade/controllers/index.js"
pin "controllers/editor_controller",        to: "universidade/controllers/editor_controller.js"
pin "controllers/blocks_editor_controller", to: "universidade/controllers/blocks_editor_controller.js"
pin "controllers/accordion_controller", to: "universidade/controllers/accordion_controller.js"
pin "controllers/modal_controller",      to: "universidade/controllers/modal_controller.js"
pin "controllers/modal_link_controller", to: "universidade/controllers/modal_link_controller.js"
pin "controllers/sortable_controller",  to: "universidade/controllers/sortable_controller.js"
pin "controllers/hierarchical_sortable_controller", to: "universidade/controllers/hierarchical_sortable_controller.js"
pin "controllers/sidebar_controller",  to: "universidade/controllers/sidebar_controller.js"
pin "controllers/carrossel_controller", to: "universidade/controllers/carrossel_controller.js"

# Sortable.js — drag & drop
pin "sortablejs", to: "https://esm.sh/sortablejs@1.15.6?bundle"

