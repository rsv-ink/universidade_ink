import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-sortable-handle]",
      onEnd: this._onEnd.bind(this)
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  _onEnd() {
    const ids = Array.from(this.element.children)
      .map(el => el.dataset.sortableId)
      .filter(Boolean)

    if (!this.urlValue || ids.length === 0) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ ids })
    })
  }
}
