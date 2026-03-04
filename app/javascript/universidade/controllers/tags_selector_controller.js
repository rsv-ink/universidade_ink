import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "dropdown", "dropdownResults", "selectedContainer", "hiddenInputsContainer"]
  static values = {
    createUrl: String
  }
  
  connect() {
    this.selectedTags = new Set()
    this.allTags = window.universidadeTags || []
    
    // Carregar tags já selecionadas
    const hiddenInputs = this.hiddenInputsContainerTarget.querySelectorAll('input[type="hidden"]')
    hiddenInputs.forEach(input => {
      this.selectedTags.add(input.value)
    })
    
    // Fechar dropdown ao clicar fora
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }
  
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeDropdown()
    }
  }
  
  onInput(event) {
    const query = event.target.value.trim().toLowerCase()
    
    if (query.length === 0) {
      this.closeDropdown()
      return
    }
    
    this.showDropdown()
    this.renderResults(query)
  }
  
  onFocus(event) {
    const query = event.target.value.trim().toLowerCase()
    if (query.length > 0) {
      this.showDropdown()
      this.renderResults(query)
    }
  }
  
  renderResults(query) {
    const filtered = this.allTags.filter(tag => 
      tag.nome.toLowerCase().includes(query) && !this.selectedTags.has(tag.id.toString())
    )
    
    let html = ''
    
    if (filtered.length > 0) {
      filtered.forEach(tag => {
        html += `
          <button type="button" 
                  class="w-full text-left px-3 py-2 hover:bg-gray-100 text-sm"
                  data-action="click->tags-selector#selectTag"
                  data-tag-id="${tag.id}"
                  data-tag-nome="${tag.nome}">
            ${tag.nome}
          </button>
        `
      })
    }
    
    // Opção para criar nova tag se não existir exata correspondência
    const exactMatch = this.allTags.find(tag => tag.nome.toLowerCase() === query)
    if (!exactMatch && query.length >= 2) {
      html += `
        <button type="button"
                class="w-full text-left px-3 py-2 bg-pink-50 hover:bg-pink-100 text-sm text-pink-700 border-t border-pink-200"
                data-action="click->tags-selector#createTag"
                data-tag-nome="${query}">
          <span class="font-medium">+ Criar tag "${query}"</span>
        </button>
      `
    }
    
    if (html === '') {
      html = '<div class="px-3 py-2 text-sm text-gray-500">Nenhuma tag encontrada</div>'
    }
    
    this.dropdownResultsTarget.innerHTML = html
  }
  
  selectTag(event) {
    event.preventDefault()
    const tagId = event.currentTarget.dataset.tagId
    const tagNome = event.currentTarget.dataset.tagNome
    
    this.addTagToSelection(tagId, tagNome)
    this.closeDropdown()
    this.searchInputTarget.value = ''
  }
  
  async createTag(event) {
    event.preventDefault()
    const tagNome = event.currentTarget.dataset.tagNome
    
    try {
      const response = await fetch('/admin/tags', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          tag: { nome: tagNome }
        })
      })
      
      if (response.ok) {
        const newTag = await response.json()
        
        // Adicionar à lista global
        this.allTags.push(newTag)
        window.universidadeTags = this.allTags
        
        // Adicionar à seleção
        this.addTagToSelection(newTag.id, newTag.nome)
        this.closeDropdown()
        this.searchInputTarget.value = ''
      } else {
        const error = await response.json()
        alert('Erro ao criar tag: ' + (error.errors ? error.errors.join(', ') : 'Erro desconhecido'))
      }
    } catch (error) {
      console.error('Erro ao criar tag:', error)
      alert('Erro ao criar tag. Tente novamente.')
    }
  }
  
  addTagToSelection(tagId, tagNome) {
    if (this.selectedTags.has(tagId.toString())) {
      return // Já selecionada
    }
    
    this.selectedTags.add(tagId.toString())
    
    // Adicionar chip visual
    const chip = document.createElement('span')
    chip.className = 'inline-flex items-center gap-1 px-2 py-1.5 bg-gray-100 text-gray-700 text-sm rounded'
    chip.dataset.tagId = tagId
    chip.innerHTML = `
      ${tagNome}
      <button type="button" 
              data-action="click->tags-selector#removeTag"
              data-tag-id="${tagId}"
              class="text-gray-500 hover:text-gray-700">
        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    
    // Inserir antes do input
    this.selectedContainerTarget.insertBefore(chip, this.searchInputTarget)
    
    // Adicionar hidden input
    const hiddenInput = document.createElement('input')
    hiddenInput.type = 'hidden'
    hiddenInput.name = 'conteudo[tag_ids][]'
    hiddenInput.value = tagId
    hiddenInput.dataset.tagId = tagId
    this.hiddenInputsContainerTarget.appendChild(hiddenInput)
  }
  
  removeTag(event) {
    event.preventDefault()
    const tagId = event.currentTarget.dataset.tagId
    
    this.selectedTags.delete(tagId)
    
    // Remover chip visual
    const chip = this.selectedContainerTarget.querySelector(`span[data-tag-id="${tagId}"]`)
    if (chip) {
      chip.remove()
    }
    
    // Remover hidden input
    const hiddenInput = this.hiddenInputsContainerTarget.querySelector(`input[data-tag-id="${tagId}"]`)
    if (hiddenInput) {
      hiddenInput.remove()
    }
  }
  
  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
  }
  
  closeDropdown() {
    this.dropdownTarget.classList.add('hidden')
  }
}
