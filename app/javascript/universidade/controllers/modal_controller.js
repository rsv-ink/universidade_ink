import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._handleKeydown = this._handleKeydown.bind(this)
    document.addEventListener("keydown", this._handleKeydown)
    // Prevent body scroll while modal is open
    document.body.style.overflow = "hidden"
  }

  disconnect() {
    document.removeEventListener("keydown", this._handleKeydown)
    document.body.style.overflow = ""
  }

  _handleKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  close() {
    const frame = document.getElementById("modal")
    if (frame) {
      frame.innerHTML = ""
      frame.removeAttribute("src")
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) this.close()
  }
}
