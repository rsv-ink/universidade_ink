import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["linkFields", "iconPreview", "previewIcon", "previewNome"]

  connect() {
    this.toggleTipo()
    this.setupListeners()
  }

  setupListeners() {
    // Listener para atualizar preview quando o ícone mudar
    const iconeField = this.element.querySelector('#sidebar_item_icone')
    if (iconeField) {
      iconeField.addEventListener('input', () => this.updatePreview())
    }

    // Listener para atualizar preview quando o nome mudar
    const nomeField = this.element.querySelector('#sidebar_item_nome')
    if (nomeField) {
      nomeField.addEventListener('input', () => this.updatePreview())
    }
  }

  toggleTipo() {
    const tipoRadios = this.element.querySelectorAll('input[name="sidebar_item[tipo]"]')
    const selectedTipo = Array.from(tipoRadios).find(radio => radio.checked)?.value

    this.linkFieldsTargets.forEach(field => {
      if (selectedTipo === 'divider') {
        field.classList.add('hidden')
      } else {
        field.classList.remove('hidden')
      }
    })
  }

  updatePreview() {
    const iconeField = this.element.querySelector('#sidebar_item_icone')
    const nomeField = this.element.querySelector('#sidebar_item_nome')
    const previewContainer = this.element.querySelector('#icon-preview')
    const previewIcon = this.element.querySelector('#preview-icon')
    const previewNome = this.element.querySelector('#preview-nome')

    if (!iconeField || !previewContainer) return

    const iconeValue = iconeField.value.trim()
    const nomeValue = nomeField?.value.trim() || 'Nome do item'

    if (iconeValue) {
      previewContainer.classList.remove('hidden')
      previewIcon.innerHTML = iconeValue
      if (previewNome) previewNome.textContent = nomeValue
    } else {
      previewContainer.classList.add('hidden')
    }
  }
}
