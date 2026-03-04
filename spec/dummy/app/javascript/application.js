// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

// Start Stimulus and make it globally available for the engine
const application = Application.start()
window.Stimulus = application

// Configure Stimulus development experience
application.debug = false

console.log("Dummy app: Stimulus initialized")

// Load engine JavaScript after Stimulus is ready
import "universidade/application"
