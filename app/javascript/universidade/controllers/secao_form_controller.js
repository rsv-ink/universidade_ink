import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Mostra/oculta painéis de acordo com o tipo de seção selecionado.
export default class extends Controller {
  static targets = ["imagemPanel", "conteudoPanel", "trilhasList", "conteudosList", "imagensList", "trilhasSearch", "conteudosSearch", "previewContainer", "previewList"]

  connect() {
    this.updatePanels()
    this.setupSortables()
    this.previewSortable = null
    
    // Organizar listas no carregamento inicial (após o DOM estar pronto)
    requestAnimationFrame(() => {
      if (this.hasTrilhasListTarget) {
        console.log("Reorganizando trilhas no connect")
        this.reorganizeList(this.trilhasListTarget)
      }
      if (this.hasConteudosListTarget) {
        console.log("Reorganizando conteúdos no connect")
        this.reorganizeList(this.conteudosListTarget)
      }
    })
  }

  disconnect() {
    this.sortables?.forEach(sortable => sortable.destroy())
    this.previewSortable?.destroy()
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
    const lists = [this.trilhasListTarget, this.conteudosListTarget].filter(Boolean)

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
    const list = label.parentElement
    
    label.classList.toggle("is-selected", event.target.checked)
    
    // Reorganizar: itens selecionados no topo, separados dos não selecionados
    this.reorganizeList(list)
  }

  reorganizeList(list) {
    console.log("reorganizeList chamado para:", list)
    const items = Array.from(list.querySelectorAll('.secao-item'))
    console.log("Total de itens:", items.length)
    
    // Sincronizar classe is-selected com estado do checkbox
    items.forEach(item => {
      const checkbox = item.querySelector('input[type="checkbox"]')
      if (checkbox) {
        if (checkbox.checked) {
          item.classList.add('is-selected')
          console.log("Item marcado como selecionado:", checkbox.value)
        } else {
          item.classList.remove('is-selected')
        }
      }
    })
    
    const selected = items.filter(item => item.classList.contains('is-selected'))
    const notSelected = items.filter(item => !item.classList.contains('is-selected'))
    
    console.log("Selecionados:", selected.length, "Não selecionados:", notSelected.length)
    
    // Remover separador existente
    const existingSeparator = list.querySelector('.items-separator')
    if (existingSeparator) {
      existingSeparator.remove()
    }
    
    // Limpar lista
    list.innerHTML = ''
    
    // Adicionar itens selecionados
    selected.forEach(item => list.appendChild(item))
    
    // Adicionar separador se houver itens selecionados E não selecionados
    if (selected.length > 0 && notSelected.length > 0) {
      const separator = document.createElement('div')
      separator.className = 'items-separator pt-3 pb-1'
      separator.innerHTML = '<div class="flex items-center gap-2"><div class="flex-1 border-t border-gray-300"></div><span class="text-xs text-gray-400 px-2">Não selecionados</span><div class="flex-1 border-t border-gray-300"></div></div>'
      list.appendChild(separator)
      console.log("Separador adicionado")
    }
    
    // Adicionar itens não selecionados
    notSelected.forEach(item => list.appendChild(item))
  }

  filterTrilhas(event) {
    const searchTerm = event.target.value.toLowerCase().trim()
    const items = this.trilhasListTarget.querySelectorAll(".secao-item")
    
    items.forEach(item => {
      const searchableText = item.dataset.searchable || ""
      const matches = searchableText.includes(searchTerm)
      item.style.display = matches ? "" : "none"
    })
    
    // Mostrar/ocultar separador baseado em itens visíveis
    this.updateSeparatorVisibility(this.trilhasListTarget)
  }

  filterConteudos(event) {
    const searchTerm = event.target.value.toLowerCase().trim()
    const items = this.conteudosListTarget.querySelectorAll(".secao-item")
    
    items.forEach(item => {
      const searchableText = item.dataset.searchable || ""
      const matches = searchableText.includes(searchTerm)
      item.style.display = matches ? "" : "none"
    })
    
    // Mostrar/ocultar separador baseado em itens visíveis
    this.updateSeparatorVisibility(this.conteudosListTarget)
  }

  updateSeparatorVisibility(list) {
    const separator = list.querySelector('.items-separator')
    if (!separator) return
    
    const items = Array.from(list.querySelectorAll('.secao-item'))
    const visibleSelected = items.filter(item => 
      item.classList.contains('is-selected') && item.style.display !== 'none'
    )
    const visibleNotSelected = items.filter(item => 
      !item.classList.contains('is-selected') && item.style.display !== 'none'
    )
    
    // Mostrar separador apenas se houver itens visíveis em ambos os grupos
    separator.style.display = (visibleSelected.length > 0 && visibleNotSelected.length > 0) ? '' : 'none'
  }

  handleImageSelect(event) {
    const files = event.target.files
    if (!files || files.length === 0) return

    // Mostrar container de preview
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.classList.remove('hidden')
    }

    // Criar previews para cada arquivo
    Array.from(files).forEach((file, index) => {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        const previewItem = this.createPreviewItem(e.target.result, file.name, index)
        if (this.hasPreviewListTarget) {
          this.previewListTarget.appendChild(previewItem)
          this.setupPreviewSortable()
        }
      }
      
      reader.readAsDataURL(file)
    })
  }

  createPreviewItem(imageSrc, fileName, index) {
    const div = document.createElement('div')
    div.className = 'secao-imagem-preview relative group bg-gray-50 border border-gray-100 rounded-lg p-2'
    div.innerHTML = `
      <div class="relative mb-2">
        <div class="absolute top-2 left-2 text-white/70 bg-black/30 rounded-md p-1 cursor-grab active:cursor-grabbing z-10" data-sortable-handle>
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M9 6h.01M9 12h.01M9 18h.01M15 6h.01M15 12h.01M15 18h.01"/>
          </svg>
        </div>
        <button type="button" 
                class="absolute top-2 right-2 text-white bg-red-500 hover:bg-red-600 rounded-md p-1 z-10"
                data-action="click->secao-form#removePreview">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
        <img src="${imageSrc}" class="w-full h-28 rounded-lg border border-gray-200 object-cover" />
      </div>
      <div class="mt-2">
        <input type="text" 
               name="secao[new_imagens_links][]" 
               placeholder="https://exemplo.com"
               class="w-full border border-gray-200 rounded px-2 py-1.5 text-xs focus:ring-pink-500 focus:border-pink-500" />
      </div>
    `
    return div
  }

  removeImage(event) {
    const imageItem = event.target.closest('.secao-imagem-item')
    if (imageItem) {
      imageItem.remove()
      this.syncImagensOrdem()
    }
  }

  removePreview(event) {
    const previewItem = event.target.closest('.secao-imagem-preview')
    if (previewItem) {
      previewItem.remove()
      
      // Se não há mais previews, esconder o container
      if (this.hasPreviewListTarget && this.previewListTarget.children.length === 0) {
        if (this.hasPreviewContainerTarget) {
          this.previewContainerTarget.classList.add('hidden')
        }
      }
    }
  }

  setupPreviewSortable() {
    // Destruir sortable existente antes de criar novo
    if (this.previewSortable) {
      this.previewSortable.destroy()
    }

    if (this.hasPreviewListTarget) {
      this.previewSortable = Sortable.create(this.previewListTarget, {
        animation: 150,
        handle: "[data-sortable-handle]",
        draggable: ".secao-imagem-preview"
      })
    }
  }
}
