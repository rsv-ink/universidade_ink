import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    this._onKeydown = (e) => {
      if (e.key === "Escape" && !this.element.hidden) this.close()
    }
    document.addEventListener("keydown", this._onKeydown)

    // Auto-hide when content is cleared (e.g. by turbo_stream.update("modal", ""))
    this._observer = new MutationObserver(() => {
      if (this.hasContentTarget && this.contentTarget.children.length === 0) {
        this.element.hidden = true
        document.body.style.overflow = ""
      }
    })
    if (this.hasContentTarget) {
      this._observer.observe(this.contentTarget, { childList: true })
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown)
    this._observer?.disconnect()
  }

  open() {
    this.element.hidden = false
    document.body.style.overflow = "hidden"
  }

  close() {
    this.element.hidden = true
    document.body.style.overflow = ""
    if (this.hasContentTarget) this.contentTarget.innerHTML = ""
  }

  closeBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
  }
}
