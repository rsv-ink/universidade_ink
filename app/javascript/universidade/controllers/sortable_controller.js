import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    console.log("Sortable controller conectado", this.element)
    console.log("URL de reordenação:", this.urlValue)
    
    if (!Sortable) {
      console.error("SortableJS não foi carregado!")
      return
    }

    try {
      this.sortable = Sortable.create(this.element, {
        animation: 150,
        handle: "[data-sortable-handle]",
        onEnd: this._onEnd.bind(this)
      })
      console.log("Sortable criado com sucesso", this.sortable)
    } catch (error) {
      console.error("Erro ao criar Sortable:", error)
    }
  }

  disconnect() {
    this.sortable?.destroy()
  }

  _onEnd() {
    console.log("Drag end detectado")
    const ids = Array.from(this.element.children)
      .map(el => el.dataset.sortableId)
      .filter(Boolean)

    console.log("IDs reordenados:", ids)

    if (!this.urlValue || ids.length === 0) {
      console.warn("URL ou IDs não disponíveis", { url: this.urlValue, ids })
      return
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    console.log("Enviando requisição para:", this.urlValue, { ids, csrfToken })

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ ids })
    })
    .then(response => {
      console.log("Resposta recebida:", response.status)
      if (!response.ok) {
        console.error("Erro na resposta:", response)
      }
    })
    .catch(error => {
      console.error("Erro na requisição:", error)
    })
  }
}
