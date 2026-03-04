import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["suggestionsContainer", "suggestionsList", "categoriaSelect"]
  static values = {
    titulo: String,
    corpo: String
  }
  
  connect() {
    this.debounceTimer = null
    this.allCategorias = window.universidadeCategorias || []
    this.allTags = window.universidadeTags || []
    
    // Escutar mudanças no título e corpo
    this.setupListeners()
    
    // Gerar sugestões iniciais se já houver conteúdo
    if (this.tituloValue || this.corpoValue) {
      this.debouncedFetchSuggestions()
    }
  }
  
  setupListeners() {
    // Escutar input no título
    const tituloInput = document.querySelector('input[name="conteudo[titulo]"]')
    if (tituloInput) {
      tituloInput.addEventListener('input', () => this.debouncedFetchSuggestions())
    }
    
    // Escutar mudanças no editor de blocos (corpo)
    // O corpo é atualizado pelo blocks-editor controller em um hidden input
    const corpoInput = document.querySelector('input[name="conteudo[corpo]"]')
    if (corpoInput) {
      // Observar mudanças no value do input hidden
      const observer = new MutationObserver(() => this.debouncedFetchSuggestions())
      observer.observe(corpoInput, { 
        attributes: true, 
        attributeFilter: ['value'] 
      })
      this.observer = observer
    }
  }
  
  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
  
  debouncedFetchSuggestions() {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions()
    }, 500)
  }
  
  async fetchSuggestions() {
    const tituloInput = document.querySelector('input[name="conteudo[titulo]"]')
    const corpoInput = document.querySelector('input[name="conteudo[corpo]"]')
    
    const titulo = tituloInput ? tituloInput.value : ''
    const corpo = corpoInput ? corpoInput.value : ''
    
    if (!titulo && !corpo) {
      this.hideSuggestions()
      return
    }
    
    try {
      const response = await fetch('/admin/tags/buscar_sugestoes', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          titulo: titulo,
          corpo: corpo
        })
      })
      
      if (response.ok) {
        const data = await response.json()
        this.renderSuggestions(data.categorias, data.tags)
      }
    } catch (error) {
      console.error('Erro ao buscar sugestões:', error)
    }
  }
  
  renderSuggestions(categorias, tags) {
    if (categorias.length === 0 && tags.length === 0) {
      this.hideSuggestions()
      return
    }
    
    let html = ''
    
    if (categorias.length > 0) {
      html += '<div class="mb-2"><span class="text-xs font-semibold text-pink-700 uppercase">Categorias:</span></div>'
      html += '<div class="flex flex-wrap gap-2 mb-3">'
      categorias.forEach(cat => {
        html += `
          <button type="button"
                  class="inline-flex items-center gap-1 px-3 py-1.5 bg-white border border-pink-300 text-pink-700 text-sm rounded-full hover:bg-pink-100 transition"
                  data-action="click->taxonomy-suggestions#addCategoria"
                  data-categoria-id="${cat.id}">
            <svg class="w-3 h-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            ${cat.nome}
          </button>
        `
      })
      html += '</div>'
    }
    
    if (tags.length > 0) {
      html += '<div class="mb-2"><span class="text-xs font-semibold text-pink-700 uppercase">Tags:</span></div>'
      html += '<div class="flex flex-wrap gap-2">'
      tags.forEach(tag => {
        html += `
          <button type="button"
                  class="inline-flex items-center gap-1 px-3 py-1.5 bg-white border border-pink-300 text-pink-700 text-sm rounded-full hover:bg-pink-100 transition"
                  data-action="click->taxonomy-suggestions#addTag"
                  data-tag-id="${tag.id}"
                  data-tag-nome="${tag.nome}">
            <svg class="w-3 h-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            ${tag.nome}
          </button>
        `
      })
      html += '</div>'
    }
    
    this.suggestionsListTarget.innerHTML = html
    this.showSuggestions()
  }
  
  addCategoria(event) {
    event.preventDefault()
    const categoriaId = event.currentTarget.dataset.categoriaId
    
    if (this.hasCategoriaSelectTarget) {
      this.categoriaSelectTarget.value = categoriaId
      
      // Disparar evento change para possíveis listeners
      this.categoriaSelectTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
    
    // Remover botão de sugestão
    event.currentTarget.remove()
    
    // Esconder seção de sugestões se não houver mais sugestões
    this.checkIfEmpty()
  }
  
  addTag(event) {
    event.preventDefault()
    const tagId = event.currentTarget.dataset.tagId
    const tagNome = event.currentTarget.dataset.tagNome
    
    // Encontrar o controller tags-selector e adicionar a tag
    const tagsSelectorElement = document.querySelector('[data-controller*="tags-selector"]')
    if (tagsSelectorElement) {
      const controller = this.application.getControllerForElementAndIdentifier(
        tagsSelectorElement, 
        'tags-selector'
      )
      
      if (controller) {
        controller.addTagToSelection(tagId, tagNome)
      }
    }
    
    // Remover botão de sugestão
    event.currentTarget.remove()
    
    // Esconder seção de sugestões se não houver mais sugestões
    this.checkIfEmpty()
  }
  
  checkIfEmpty() {
    const buttons = this.suggestionsListTarget.querySelectorAll('button')
    if (buttons.length === 0) {
      this.hideSuggestions()
    }
  }
  
  showSuggestions() {
    this.suggestionsContainerTarget.classList.remove('hidden')
  }
  
  hideSuggestions() {
    this.suggestionsContainerTarget.classList.add('hidden')
  }
  
  onCategoriaChange(event) {
    // Você pode adicionar lógica adicional quando a categoria é alterada manualmente
  }
}
