import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  toggle(event) {
    event.preventDefault()
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle("-translate-x-full")
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle("hidden")
    }
  }

  close() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("-translate-x-full")
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
  }
}
