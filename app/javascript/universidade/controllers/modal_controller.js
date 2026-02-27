import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "content"]

  connect() {
    // Observa mudanças no conteúdo — quando receber HTML, abre o modal
    this.observer = new MutationObserver(() => {
      if (this.hasContentTarget && this.contentTarget.innerHTML.trim() !== "") {
        this.open()
      }
    })
    this.observer.observe(this.contentTarget, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  open() {
    this.element.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close(event) {
    if (event?.type === "turbo:submit-end" && !event.detail.success) return
    this.element.classList.add("hidden")
    document.body.style.overflow = ""
    setTimeout(() => {
      if (this.hasContentTarget) this.contentTarget.innerHTML = ""
    }, 200)
  }

  closeOnOverlay(event) {
    if (event.target === this.element) {
      this.close()
    }
  }

  reloadOnSuccess(event) {
    if (!event.detail.success) return
    window.location.reload()
  }
}
