import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const url = event.currentTarget.href || event.currentTarget.dataset.url
    if (!url) return

    const modalEl = document.getElementById("admin-modal")
    if (!modalEl) return

    fetch(url, {
      headers: {
        "Accept": "text/html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
      .then(r => { if (!r.ok) throw new Error(r.status); return r.text() })
      .then(html => {
        const contentEl = modalEl.querySelector("[data-modal-target='content']")
        if (contentEl) contentEl.innerHTML = html
        const ctrl = this.application.getControllerForElementAndIdentifier(modalEl, "modal")
        if (ctrl) ctrl.open()
      })
      .catch(err => console.error("[modal-link] Failed:", err))
  }
}
