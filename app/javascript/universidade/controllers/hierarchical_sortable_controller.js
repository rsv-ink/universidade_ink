import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    cursoUrl: String,
    moduloUrl: String,
    trilhaUrl: String,
    artigoUrl: String
  }

  connect() {
    this.sortables = []
    this.draggedChildren = []
    
    // Create sortable for curso tbodys (top level)
    const cursoSortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-sortable-handle]",
      draggable: "tbody[id^='curso_group_']",
      filter: "tbody#avulso_group", // Don't drag avulso group
      onEnd: this._onEndCurso.bind(this)
    })
    this.sortables.push(cursoSortable)
    
    // For each curso tbody and avulso tbody, create sortables for nested items
    const tbodies = [
      ...this.element.querySelectorAll('tbody[id^="curso_group_"]'),
      ...this.element.querySelectorAll('tbody#avulso_group')
    ]
    
    tbodies.forEach(tbody => {
      // Create sortable group for this tbody that handles nested types
      const sortable = Sortable.create(tbody, {
        animation: 150,
        handle: "[data-sortable-handle]",
        draggable: "tr[data-sortable-id]", // Only rows with sortable-id
        filter: "tr[id^='curso_']", // Don't allow dragging curso rows within tbody
        onStart: this._onStart.bind(this),
        onMove: this._onMove.bind(this),
        onEnd: this._onEnd.bind(this)
      })
      
      this.sortables.push(sortable)
    })
  }

  disconnect() {
    this.sortables.forEach(s => s?.destroy())
  }

  _onStart(evt) {
    const item = evt.item
    const itemId = item.id
    
    this.draggedChildren = []
    
    // If dragging a modulo, collect all its trilhas and artigos
    if (itemId.startsWith('modulo_')) {
      const children = this._collectModuloChildren(item)
      this.draggedChildren = children
      
      // Mark children as being dragged
      children.forEach(child => {
        child.classList.add('dragging-with-parent')
        child.style.display = 'none'
      })
    }
    // If dragging a trilha, collect all its artigos
    else if (itemId.startsWith('trilha_')) {
      const children = this._collectTrilhaChildren(item)
      this.draggedChildren = children
      
      // Mark children as being dragged
      children.forEach(child => {
        child.classList.add('dragging-with-parent')
        child.style.display = 'none'
      })
    }
  }

  _collectModuloChildren(moduloRow) {
    const children = []
    let sibling = moduloRow.nextElementSibling
    
    // Collect all trilhas and artigos until we hit another modulo or end
    while (sibling) {
      if (sibling.id.startsWith('modulo_') || sibling.id.startsWith('curso_')) {
        break
      }
      if (sibling.id.startsWith('trilha_') || sibling.id.startsWith('artigo_')) {
        children.push(sibling)
      }
      sibling = sibling.nextElementSibling
    }
    
    return children
  }

  _collectTrilhaChildren(trilhaRow) {
    const children = []
    let sibling = trilhaRow.nextElementSibling
    
    // Collect all artigos until we hit a modulo, trilha, or end
    while (sibling) {
      if (sibling.id.startsWith('modulo_') || sibling.id.startsWith('trilha_') || sibling.id.startsWith('curso_')) {
        break
      }
      if (sibling.id.startsWith('artigo_')) {
        children.push(sibling)
      }
      sibling = sibling.nextElementSibling
    }
    
    return children
  }

  _onMove(evt) {
    const draggedEl = evt.dragged
    const relatedEl = evt.related
    
    // Don't allow dropping on hidden children
    if (relatedEl.classList.contains('dragging-with-parent')) {
      return false
    }
    
    const draggedType = this._getElementType(draggedEl)
    const relatedType = this._getElementType(relatedEl)
    
    // If dragging a modulo
    if (draggedType === 'modulo') {
      // Can only drop next to other modulos or at the beginning
      // Not allowed to drop in the middle of trilhas or artigos
      if (relatedType === 'trilha' || relatedType === 'artigo') {
        // Check if the related element belongs to a modulo
        const relatedParent = this._findPreviousSibling(relatedEl, 'modulo_')
        if (relatedParent) {
          // Don't allow dropping between a modulo and its children
          return false
        }
      }
      return true
    }
    
    // If dragging a trilha
    if (draggedType === 'trilha') {
      // Can only drop next to other trilhas of the same modulo
      // Not allowed to drop in the middle of artigos
      if (relatedType === 'artigo') {
        return false
      }
      
      // If dropping next to a trilha, check if they have the same parent modulo
      if (relatedType === 'trilha') {
        const draggedModulo = this._findPreviousSibling(draggedEl, 'modulo_')
        const relatedModulo = this._findPreviousSibling(relatedEl, 'modulo_')
        
        const draggedModuloId = draggedModulo ? draggedModulo.id : null
        const relatedModuloId = relatedModulo ? relatedModulo.id : null
        
        // Only allow if same parent modulo
        return draggedModuloId === relatedModuloId
      }
      
      // If dropping next to a modulo, that's OK (insert after the modulo)
      if (relatedType === 'modulo') {
        return true
      }
    }
    
    // If dragging an artigo
    if (draggedType === 'artigo') {
      // Can only drop next to other artigos of the same trilha
      if (relatedType !== 'artigo') {
        return false
      }
      
      const draggedTrilha = this._findPreviousSibling(draggedEl, 'trilha_')
      const relatedTrilha = this._findPreviousSibling(relatedEl, 'trilha_')
      
      const draggedTrilhaId = draggedTrilha ? draggedTrilha.id : null
      const relatedTrilhaId = relatedTrilha ? relatedTrilha.id : null
      
      // Only allow if same parent trilha
      return draggedTrilhaId === relatedTrilhaId
    }
    
    return true
  }

  _getElementType(element) {
    if (!element || !element.id) return null
    
    if (element.id.startsWith('modulo_')) return 'modulo'
    if (element.id.startsWith('trilha_')) return 'trilha'
    if (element.id.startsWith('artigo_')) return 'artigo'
    if (element.id.startsWith('curso_')) return 'curso'
    
    return null
  }

  _onEndCurso(evt) {
    const item = evt.item
    
    // Collect IDs of all curso tbodys in order
    const ids = Array.from(this.element.querySelectorAll('tbody[id^="curso_group_"]'))
      .map(tbody => tbody.dataset.sortableId)
      .filter(Boolean)
    
    if (ids.length === 0 || !this.cursoUrlValue) return
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    fetch(this.cursoUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ ids })
    })
  }

  _onEnd(evt) {
    const item = evt.item
    const itemId = item.id
    
    // Move children after the parent item
    if (this.draggedChildren.length > 0) {
      this.draggedChildren.forEach(child => {
        child.style.display = ''
        child.classList.remove('dragging-with-parent')
        item.parentNode.insertBefore(child, item.nextSibling)
      })
      this.draggedChildren = []
    }
    
    // Determine type and collect siblings of same type
    let type, url, parentId
    
    if (itemId.startsWith('modulo_')) {
      type = 'modulo'
      url = this.moduloUrlValue
      // Get curso_id from parent tbody
      const tbody = item.closest('tbody[id^="curso_group_"]')
      parentId = tbody ? tbody.id.replace('curso_group_', '') : null
    } else if (itemId.startsWith('trilha_')) {
      type = 'trilha'
      url = this.trilhaUrlValue
      // Get modulo_id by finding previous modulo row
      const moduloRow = this._findPreviousSibling(item, 'modulo_')
      parentId = moduloRow ? moduloRow.id.replace('modulo_', '') : null
    } else if (itemId.startsWith('artigo_')) {
      type = 'artigo'
      url = this.artigoUrlValue
      // Get trilha_id by finding previous trilha row
      const trilhaRow = this._findPreviousSibling(item, 'trilha_')
      parentId = trilhaRow ? trilhaRow.id.replace('trilha_', '') : null
    }
    
    if (!type || !url) return
    
    // Collect IDs of same type in order from current parent
    const ids = this._collectIdsOfType(item.parentElement, type, parentId)
    
    if (ids.length === 0) return
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    const body = { ids }
    if (type === 'artigo' && parentId) {
      body.trilha_id = parentId
    }
    
    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify(body)
    })
  }

  _findPreviousSibling(element, prefix) {
    let sibling = element.previousElementSibling
    while (sibling) {
      if (sibling.id && sibling.id.startsWith(prefix)) {
        return sibling
      }
      sibling = sibling.previousElementSibling
    }
    return null
  }

  _collectIdsOfType(tbody, type, parentId) {
    const rows = Array.from(tbody.querySelectorAll(`tr[id^="${type}_"]`))
    const ids = []
    
    // For nested items, we need to ensure we only get items belonging to the same parent
    if (type === 'modulo') {
      // All modulos in this tbody belong to the same curso
      rows.forEach(row => {
        const id = row.dataset.sortableId
        if (id) ids.push(id)
      })
    } else if (type === 'trilha') {
      // Get only trilhas that belong to the same modulo (right after the modulo row)
      let currentModuloId = null
      Array.from(tbody.children).forEach(row => {
        if (row.id.startsWith('modulo_')) {
          currentModuloId = row.id.replace('modulo_', '')
        } else if (row.id.startsWith('trilha_') && currentModuloId === parentId) {
          const id = row.dataset.sortableId
          if (id) ids.push(id)
        } else if (row.id.startsWith('modulo_')) {
          currentModuloId = row.id.replace('modulo_', '')
        }
      })
    } else if (type === 'artigo') {
      // Get only artigos that belong to the same trilha
      let currentTrilhaId = null
      Array.from(tbody.children).forEach(row => {
        if (row.id.startsWith('trilha_')) {
          currentTrilhaId = row.id.replace('trilha_', '')
        } else if (row.id.startsWith('artigo_') && currentTrilhaId === parentId) {
          const id = row.dataset.sortableId
          if (id) ids.push(id)
        } else if (row.id.startsWith('modulo_') || row.id.startsWith('trilha_')) {
          if (row.id.startsWith('trilha_')) {
            currentTrilhaId = row.id.replace('trilha_', '')
          }
        }
      })
    }
    
    return ids
  }
}
