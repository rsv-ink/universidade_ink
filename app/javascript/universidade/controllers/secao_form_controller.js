import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Mostra/oculta painéis de acordo com o tipo de seção selecionado.
export default class extends Controller {
  static targets = ["imagemPanel", "conteudoPanel", "cursosList", "artigosList", "imagensList"]

  connect() {
    this.updatePanels()
    this.setupSortables()
  }

  disconnect() {
    this.sortables?.forEach(sortable => sortable.destroy())
  }

  onTipoChange() {
    this.updatePanels()
  }

  updatePanels() {
    const checked = this.element.querySelector('input[name="secao[tipo]"]:checked')
    const tipo = checked?.value

    this.imagemPanelTargets.forEach(el => { el.hidden = tipo !== "imagem" })
    this.conteudoPanelTargets.forEach(el => { el.hidden = tipo !== "conteudo" })
  }

  setupSortables() {
    this.sortables = []
    const lists = [this.cursosListTarget, this.artigosListTarget].filter(Boolean)

    lists.forEach(list => {
      this.sortables.push(Sortable.create(list, {
        animation: 150,
        handle: "[data-sortable-handle]",
        draggable: ".secao-item.is-selected"
      }))
    })

    if (this.hasImagensListTarget) {
      this.sortables.push(Sortable.create(this.imagensListTarget, {
        animation: 150,
        handle: "[data-sortable-handle]",
        draggable: ".secao-imagem-item",
        onEnd: () => this.syncImagensOrdem()
      }))
    }
  }

  syncImagensOrdem() {
    if (!this.hasImagensListTarget) return
    const items = this.imagensListTarget.querySelectorAll(".secao-imagem-item")
    items.forEach(item => {
      const input = item.querySelector('input[name="secao[imagens_ordem][]"]')
      if (input) item.appendChild(input)
    })
  }

  toggleSelection(event) {
    const label = event.target.closest(".secao-item")
    if (!label) return
    label.classList.toggle("is-selected", event.target.checked)
  }
}
