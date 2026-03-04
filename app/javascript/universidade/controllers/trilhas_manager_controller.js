import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trilhasList", "trilhasDropdown", "selectedCount", "applyButton", "searchInput", "trilhasContainer"]
  static values = { trilhaInicial: Object, moduloInicialId: String }
  
  connect() {
    this.selectedTrilhas = new Set()
    this.updateSelectedCount()
    
    // Vincular trilha inicial se fornecida
    if (this.hasTrilhaInicialValue && this.trilhaInicialValue.id) {
      this.vincularTrilhaInicial()
    }
  }
  
  vincularTrilhaInicial() {
    const trilha = this.trilhaInicialValue
    const moduloId = this.hasModuloInicialIdValue ? this.moduloInicialIdValue : null
    
    // Adicionar a trilha à lista visualizada com o módulo pré-selecionado
    this.addTrilhaRow(trilha, moduloId)
    
    // Marcar o checkbox correspondente
    const checkbox = this.element.querySelector(`input[type="checkbox"][value="${trilha.id}"]`)
    if (checkbox) {
      checkbox.checked = true
      this.selectedTrilhas.add(trilha.id.toString())
      this.updateSelectedCount()
    }
  }

  filterTrilhas(event) {
    const searchTerm = event.target.value.toLowerCase()
    const labels = this.trilhasContainerTarget.querySelectorAll('label')
    
    labels.forEach(label => {
      const trilhaNome = label.textContent.toLowerCase()
      if (trilhaNome.includes(searchTerm)) {
        label.style.display = 'flex'
      } else {
        label.style.display = 'none'
      }
    })
  }

  toggleTrilha(event) {
    const checkbox = event.target
    const trilhaId = checkbox.value
    
    if (checkbox.checked) {
      this.selectedTrilhas.add(trilhaId)
    } else {
      this.selectedTrilhas.delete(trilhaId)
    }
    
    this.updateSelectedCount()
  }

  updateSelectedCount() {
    const count = this.selectedTrilhas.size
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = count > 0 ? `(${count})` : ""
    }
    
    if (this.hasApplyButtonTarget) {
      this.applyButtonTarget.disabled = count === 0
    }
  }

  aplicar(event) {
    event.preventDefault()
    
    // Get selected trilhas data
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
    const trilhasData = []
    
    checkboxes.forEach(cb => {
      const trilhaId = cb.value
      const trilhaNome = cb.dataset.trilhaNome
      trilhasData.push({ id: trilhaId, nome: trilhaNome })
    })
    
    // Add trilhas to the list
    trilhasData.forEach(trilha => {
      this.addTrilhaRow(trilha)
    })
    
    // Reset selection
    this.resetDropdown()
  }

  addTrilhaRow(trilha, moduloIdInicial = null) {
    // Check if trilha is already in the list
    const existingRow = this.trilhasListTarget.querySelector(`[data-trilha-id="${trilha.id}"]`)
    if (existingRow) return
    
    // Get modulos for this trilha
    const modulosSelect = this.buildModulosSelect(trilha.id, moduloIdInicial)
    
    const row = document.createElement('div')
    row.dataset.trilhaId = trilha.id
    row.className = "flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
    row.innerHTML = `
      <div class="flex-1">
        <p class="text-sm font-medium text-gray-900">${trilha.nome}</p>
        <input type="hidden" name="trilhas[]" value="${trilha.id}">
      </div>
      <div class="flex-1">
        ${modulosSelect}
      </div>
      <button type="button" 
              data-action="click->trilhas-manager#removeTrilha"
              class="text-red-600 hover:text-red-700 p-1">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    
    this.trilhasListTarget.appendChild(row)
  }

  buildModulosSelect(trilhaId, moduloIdSelecionado = null) {
    const modulosData = JSON.parse(this.element.dataset.trilhasManagerModulosValue || '[]')
    const trilhaModulos = modulosData.filter(m => m.trilha_id.toString() === trilhaId.toString())
    
    let options = '<option value="">Nenhum módulo</option>'
    trilhaModulos.forEach(modulo => {
      const selected = moduloIdSelecionado && modulo.id.toString() === moduloIdSelecionado.toString() ? 'selected' : ''
      options += `<option value="${modulo.id}" ${selected}>${modulo.nome}</option>`
    })
    
    return `
      <select name="modulos[${trilhaId}]" 
              class="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-transparent">
        ${options}
      </select>
    `
  }

  removeTrilha(event) {
    const row = event.target.closest('[data-trilha-id]')
    const trilhaId = row.dataset.trilhaId
    
    // Uncheck the checkbox in dropdown
    const checkbox = this.element.querySelector(`input[type="checkbox"][value="${trilhaId}"]`)
    if (checkbox) {
      checkbox.checked = false
      this.selectedTrilhas.delete(trilhaId)
      this.updateSelectedCount()
    }
    
    row.remove()
  }

  resetDropdown() {
    // Uncheck all checkboxes
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(cb => cb.checked = false)
    
    this.selectedTrilhas.clear()
    this.updateSelectedCount()
    
    // Close dropdown
    if (this.hasTrilhasDropdownTarget) {
      this.trilhasDropdownTarget.classList.add('hidden')
    }
  }

  toggleDropdown(event) {
    event.preventDefault()
    if (this.hasTrilhasDropdownTarget) {
      this.trilhasDropdownTarget.classList.toggle('hidden')
    }
  }

  closeDropdown() {
    if (this.hasTrilhasDropdownTarget) {
      setTimeout(() => {
        this.trilhasDropdownTarget.classList.add('hidden')
        // Clear search and show all trilhas
        if (this.hasSearchInputTarget) {
          this.searchInputTarget.value = ''
          const labels = this.trilhasContainerTarget.querySelectorAll('label')
          labels.forEach(label => label.style.display = 'flex')
        }
      }, 200)
    }
  }
}
