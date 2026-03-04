import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "dropdown", "dropdownResults", "hiddenInput", "displayText"]
  static values = {
    autoSubmit: { type: Boolean, default: false }
  }
  
  connect() {
    this.allCategorias = window.universidadeCategorias || []
    this.selectedCategoriaId = this.hasHiddenInputTarget ? this.hiddenInputTarget.value : ''
    
    // Atualizar texto exibido com a categoria atual
    this.updateDisplayText()
    
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
    this.renderResults(query)
  }
  
  toggleDropdown(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (!this.hasDropdownTarget) {
      return
    }
    
    if (this.dropdownTarget.classList.contains('hidden')) {
      this.showDropdown()
      // Focar no input de busca após abrir
      setTimeout(() => {
        if (this.hasSearchInputTarget) {
          this.searchInputTarget.focus()
        }
      }, 50)
    } else {
      this.closeDropdown()
    }
  }
  
  renderResults(query) {
    const filtered = this.allCategorias.filter(categoria => 
      categoria.nome.toLowerCase().includes(query)
    )
    
    let html = ''
    
    // Opção para limpar seleção
    if (this.selectedCategoriaId) {
      html += `
        <button type="button" 
                class="w-full text-left px-3 py-2 hover:bg-gray-100 text-sm text-gray-500 border-b border-gray-200"
                data-action="click->categoria-selector#clearSelection">
          <span class="italic">Nenhuma categoria</span>
        </button>
      `
    }
    
    if (filtered.length > 0) {
      filtered.forEach(categoria => {
        const isSelected = this.selectedCategoriaId === categoria.id.toString()
        const bgClass = isSelected ? 'bg-pink-50' : 'hover:bg-gray-100'
        const textClass = isSelected ? 'text-pink-700 font-medium' : ''
        
        html += `
          <div class="flex items-center gap-2 px-3 py-2 ${bgClass} group">
            <button type="button" 
                    class="flex-1 text-left text-sm ${textClass}"
                    data-action="click->categoria-selector#selectCategoria"
                    data-categoria-id="${categoria.id}"
                    data-categoria-nome="${categoria.nome}">
              ${categoria.nome}
              ${isSelected ? '<span class="ml-2">✓</span>' : ''}
            </button>
            <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
              <button type="button"
                      title="Editar categoria"
                      data-action="click->categoria-selector#editCategoria"
                      data-categoria-id="${categoria.id}"
                      data-categoria-nome="${categoria.nome}"
                      class="p-1 text-gray-400 hover:text-blue-600 rounded transition-colors">
                <svg class="w-3.5 h-3.5 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/>
                </svg>
              </button>
              <button type="button"
                      title="Excluir categoria"
                      data-action="click->categoria-selector#deleteCategoria"
                      data-categoria-id="${categoria.id}"
                      data-categoria-nome="${categoria.nome}"
                      class="p-1 text-gray-400 hover:text-red-600 rounded transition-colors">
                <svg class="w-3.5 h-3.5 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                </svg>
              </button>
            </div>
          </div>
        `
      })
    }
    
    // Opção para criar nova categoria se não existir exata correspondência
    const exactMatch = this.allCategorias.find(cat => cat.nome.toLowerCase() === query)
    if (!exactMatch && query.length >= 2) {
      html += `
        <button type="button"
                class="w-full text-left px-3 py-2 bg-pink-50 hover:bg-pink-100 text-sm text-pink-700 border-t border-pink-200"
                data-action="click->categoria-selector#createCategoria"
                data-categoria-nome="${query}">
          <span class="font-medium">+ Criar categoria "${query}"</span>
        </button>
      `
    }
    
    if (html === '' && !this.selectedCategoriaId) {
      html = '<div class="px-3 py-2 text-sm text-gray-500">Nenhuma categoria encontrada</div>'
    }
    
    if (this.hasDropdownResultsTarget) {
      this.dropdownResultsTarget.innerHTML = html
    }
  }
  
  selectCategoria(event) {
    event.preventDefault()
    const categoriaId = event.currentTarget.dataset.categoriaId
    const categoriaNome = event.currentTarget.dataset.categoriaNome
    
    this.setCategoria(categoriaId, categoriaNome)
    this.closeDropdown()
    this.searchInputTarget.value = ''
  }
  
  clearSelection(event) {
    event.preventDefault()
    this.setCategoria('', 'Nenhuma categoria')
    this.closeDropdown()
    this.searchInputTarget.value = ''
  }
  
  async createCategoria(event) {
    event.preventDefault()
    const categoriaNome = event.currentTarget.dataset.categoriaNome
    
    try {
      const response = await fetch('/admin/categorias', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          categoria: { nome: categoriaNome }
        })
      })
      
      if (response.ok) {
        const newCategoria = await response.json()
        
        // Adicionar à lista global
        this.allCategorias.push(newCategoria)
        window.universidadeCategorias = this.allCategorias
        
        // Selecionar a nova categoria
        this.setCategoria(newCategoria.id, newCategoria.nome)
        this.closeDropdown()
        this.searchInputTarget.value = ''
      } else {
        const error = await response.json()
        alert('Erro ao criar categoria: ' + (error.errors || error.error || 'Erro desconhecido'))
      }
    } catch (error) {
      console.error('Erro ao criar categoria:', error)
      alert('Erro ao criar categoria. Tente novamente.')
    }
  }
  
  async editCategoria(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const categoriaId = event.currentTarget.dataset.categoriaId
    const categoriaNomeAtual = event.currentTarget.dataset.categoriaNome
    
    const novoNome = prompt('Editar categoria:', categoriaNomeAtual)
    
    if (!novoNome || novoNome.trim() === '' || novoNome === categoriaNomeAtual) {
      return
    }
    
    try {
      const response = await fetch(`/admin/categorias/${categoriaId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          categoria: { nome: novoNome.trim() }
        })
      })
      
      if (response.ok) {
        const updatedCategoria = await response.json()
        
        // Atualizar na lista global
        const index = this.allCategorias.findIndex(c => c.id.toString() === categoriaId)
        if (index !== -1) {
          this.allCategorias[index] = updatedCategoria
          window.universidadeCategorias = this.allCategorias
        }
        
        // Se é a categoria selecionada, atualizar o display
        if (this.selectedCategoriaId === categoriaId) {
          this.updateDisplayText(updatedCategoria.nome)
        }
        
        // Re-renderizar os resultados
        const query = this.hasSearchInputTarget ? this.searchInputTarget.value.trim().toLowerCase() : ''
        this.renderResults(query)
      } else {
        const error = await response.json()
        alert('Erro ao editar categoria: ' + (error.errors || error.error || 'Erro desconhecido'))
      }
    } catch (error) {
      console.error('Erro ao editar categoria:', error)
      alert('Erro ao editar categoria. Tente novamente.')
    }
  }
  
  async deleteCategoria(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const categoriaId = event.currentTarget.dataset.categoriaId
    const categoriaNome = event.currentTarget.dataset.categoriaNome
    
    if (!confirm(`Tem certeza que deseja excluir a categoria "${categoriaNome}"?\n\nOs conteúdos vinculados a ela ficarão sem categoria.`)) {
      return
    }
    
    try {
      const response = await fetch(`/admin/categorias/${categoriaId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      if (response.ok) {
        // Remover da lista global
        this.allCategorias = this.allCategorias.filter(c => c.id.toString() !== categoriaId)
        window.universidadeCategorias = this.allCategorias
        
        // Se é a categoria selecionada, limpar seleção
        if (this.selectedCategoriaId === categoriaId) {
          this.setCategoria('', 'Nenhuma categoria')
        }
        
        // Re-renderizar os resultados
        const query = this.hasSearchInputTarget ? this.searchInputTarget.value.trim().toLowerCase() : ''
        this.renderResults(query)
      } else {
        const error = await response.json()
        alert('Erro ao excluir categoria: ' + (error.errors || error.error || 'Erro desconhecido'))
      }
    } catch (error) {
      console.error('Erro ao excluir categoria:', error)
      alert('Erro ao excluir categoria. Tente novamente.')
    }
  }
  
  setCategoria(categoriaId, categoriaNome) {
    this.selectedCategoriaId = categoriaId
    this.hiddenInputTarget.value = categoriaId
    this.updateDisplayText(categoriaNome)
    
    // Se auto-submit estiver ativado, submeter o formulário
    if (this.autoSubmitValue) {
      const form = this.element.closest('form')
      if (form) {
        form.requestSubmit()
      }
    }
  }
  
  updateDisplayText(categoriaNome = null) {
    if (!categoriaNome && this.selectedCategoriaId) {
      const categoria = this.allCategorias.find(c => c.id.toString() === this.selectedCategoriaId)
      categoriaNome = categoria ? categoria.nome : 'Nenhuma categoria'
    } else if (!categoriaNome) {
      categoriaNome = 'Nenhuma categoria'
    }
    
    if (this.hasDisplayTextTarget) {
      this.displayTextTarget.textContent = categoriaNome
    }
  }
  
  showDropdown() {
    if (!this.hasDropdownTarget) {
      return
    }
    this.dropdownTarget.classList.remove('hidden')
    // Renderizar todas as categorias inicialmente
    this.renderResults('')
  }
  
  closeDropdown() {
    if (!this.hasDropdownTarget) {
      return
    }
    this.dropdownTarget.classList.add('hidden')
    // Limpar o campo de busca ao fechar
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ''
    }
  }
}
