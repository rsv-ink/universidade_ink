# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "https://cdn.jsdelivr.net/npm/@hotwired/turbo-rails@8.0.12/+esm", preload: true
pin "@hotwired/stimulus", to: "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Engine JavaScript - loaded by application.js after Stimulus is ready
pin "universidade/application", to: "universidade/application.js"

# Sortable.js — drag & drop
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/+esm"

# Engine importmap with all controllers will be merged automatically by the initializer


