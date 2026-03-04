import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    trilhaUrl: String,
    moduloUrl: String,
    conteudoUrl: String
  }

  connect() {
    this.sortables = []
    this.draggedChildren = []
    
    // Create sortable for trilha tbodys (top level)
    const trilhaSortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-sortable-handle]",
      draggable: "tbody[id^='trilha_group_']",
      filter: "tbody#avulso_group", // Don't drag avulso group
      onEnd: this._onEndTrilha.bind(this)
    })
    this.sortables.push(trilhaSortable)
    
    // For each trilha tbody and avulso tbody, create sortables for nested items
    const tbodies = [
      ...this.element.querySelectorAll('tbody[id^="trilha_group_"]'),
      ...this.element.querySelectorAll('tbody#avulso_group')
    ]
    
    tbodies.forEach(tbody => {
      // Create sortable group for this tbody that handles nested types (modulo, conteudo)
      const sortable = Sortable.create(tbody, {
        animation: 150,
        handle: "[data-sortable-handle]",
        draggable: "tr[data-sortable-id]", // Only rows with sortable-id
        filter: "tr[id^='trilha_']", // Don't allow dragging trilha rows within tbody
        group: {
          name: "trilha-items",
          pull: true,
          put: (to, from, dragEl) => {
            if (to === from) return true
            return !!(dragEl && dragEl.id && dragEl.id.startsWith("conteudo_") && dragEl.dataset.parentType === "trilha")
          }
        },
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
    this.dragContext = null
    
    // If dragging a modulo, collect all its conteudos
    if (itemId.startsWith('modulo_')) {
      const children = this._collectModuloChildren(item)
      this.draggedChildren = children
      
      // Mark children as being dragged
      children.forEach(child => {
        child.classList.add('dragging-with-parent')
        child.style.display = 'none'
      })
    }

    if (itemId.startsWith('conteudo_')) {
      const fromParentType = item.dataset.parentType
      const fromParentId = item.dataset.parentId
      const fromTrilhaId = item.closest('tbody[id^="trilha_group_"]')?.id.replace('trilha_group_', '')

      this.dragContext = {
        fromParentType,
        fromParentId,
        fromTrilhaId
      }
    }
  }

  _collectModuloChildren(moduloRow) {
    const children = []
    let sibling = moduloRow.nextElementSibling
    
    // Collect all conteudos until we hit another modulo, trilha or end
    while (sibling) {
      if (sibling.id.startsWith('modulo_') || sibling.id.startsWith('trilha_')) {
        break
      }
      if (sibling.id.startsWith('conteudo_')) {
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
      // Can only drop next to other modulos
      // Not allowed to drop in the middle of conteudos
      if (relatedType === 'conteudo') {
        // Check if the related element belongs to a modulo
        const relatedParent = this._findPreviousSibling(relatedEl, 'modulo_')
        if (relatedParent) {
          // Don't allow dropping between a modulo and its children
          return false
        }
      }
      return true
    }
    
    // If dragging a conteudo
    if (draggedType === 'conteudo') {
      // Can drop next to other conteudos or modulos
      // Need to check if they have the same parent (modulo or trilha)
      
      const draggedParentType = draggedEl.dataset.parentType // "modulo" or "trilha"
      const relatedParentType = relatedEl.dataset.parentType
      
      if (relatedType === 'modulo') {
        // If conteudo has modulo_id, cannot drop next to modulo (different level)
        if (draggedParentType === 'modulo') {
          return false
        }
        // Conteudo solto pode ser reposicionado perto de modulos
        return true
      }
      
      if (relatedType === 'conteudo') {
        if (draggedParentType !== relatedParentType) return false
        
        // If both have modulo parent, check same modulo_id
        if (draggedParentType === 'modulo') {
          const draggedParentId = draggedEl.dataset.parentId
          const relatedParentId = relatedEl.dataset.parentId
          return draggedParentId === relatedParentId
        }
        
        // If both have trilha parent (soltos), check same trilha_id
        if (draggedParentType === 'trilha') {
          return true
        }
      }
    }
    
    return true
  }

  _getElementType(element) {
    if (!element || !element.id) return null
    
    if (element.id.startsWith('modulo_')) return 'modulo'
    if (element.id.startsWith('conteudo_')) return 'conteudo'
    if (element.id.startsWith('trilha_')) return 'trilha'
    
    return null
  }

  _onEndTrilha(evt) {
    const item = evt.item
    
    // Collect IDs of all trilha tbodys in order
    const ids = Array.from(this.element.querySelectorAll('tbody[id^="trilha_group_"]'))
      .map(tbody => tbody.dataset.sortableId)
      .filter(Boolean)
    
    if (ids.length === 0 || !this.trilhaUrlValue) return
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    fetch(this.trilhaUrlValue, {
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
    let type, url, parentId, parentType
    
    if (itemId.startsWith('modulo_')) {
      this._reflowModuloChildren(item.parentElement)
      type = 'modulo'
      url = this.moduloUrlValue
      // Get trilha_id from parent tbody
      const tbody = item.closest('tbody[id^="trilha_group_"]')
      parentId = tbody ? tbody.id.replace('trilha_group_', '') : null
    } else if (itemId.startsWith('conteudo_')) {
      type = 'conteudo'
      url = this.conteudoUrlValue
      
      // Get parent info from data attributes
      parentType = item.dataset.parentType // "modulo" or "trilha"
      const toTrilhaId = item.closest('tbody[id^="trilha_group_"]')?.id.replace('trilha_group_', '')
      
      if (parentType === 'modulo') {
        // Get modulo_id by finding previous modulo row
        const moduloRow = this._findPreviousSibling(item, 'modulo_')
        parentId = moduloRow ? moduloRow.id.replace('modulo_', '') : null
      } else if (parentType === 'trilha') {
        parentId = toTrilhaId
        if (parentId) item.dataset.parentId = parentId
      }
    }
    
    if (!type || !url) return
    
    // Collect IDs of same type in order from current parent
    const ids = this._collectIdsOfType(item.parentElement, type, parentId, parentType)
    
    if (ids.length === 0) return
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    const body = { ids }
    if (type === 'conteudo') {
      if (this.dragContext?.fromTrilhaId && parentType === 'trilha' && parentId && this.dragContext.fromTrilhaId !== parentId) {
        body.from_trilha_id = this.dragContext.fromTrilhaId
      }
      if (parentType === 'modulo' && parentId) {
        body.modulo_id = parentId
      } else if (parentType === 'trilha' && parentId) {
        body.trilha_id = parentId
      }
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

  _reflowModuloChildren(tbody) {
    if (!tbody) return

    const rows = Array.from(tbody.querySelectorAll("tr"))
    const moduleRows = rows.filter(row => row.id?.startsWith("modulo_"))
    const moduleChildrenMap = {}
    const trilhaChildren = []

    rows.forEach(row => {
      if (!row.id?.startsWith("conteudo_")) return
      const parentType = row.dataset.parentType
      const parentId = row.dataset.parentId
      if (parentType === "modulo" && parentId) {
        moduleChildrenMap[parentId] ||= []
        moduleChildrenMap[parentId].push(row)
      } else if (parentType === "trilha") {
        trilhaChildren.push(row)
      }
    })

    const fragment = document.createDocumentFragment()
    moduleRows.forEach(modRow => {
      fragment.appendChild(modRow)
      const modId = modRow.id.replace("modulo_", "")
      const children = moduleChildrenMap[modId] || []
      children.forEach(child => fragment.appendChild(child))
    })

    trilhaChildren.forEach(child => fragment.appendChild(child))
    tbody.appendChild(fragment)
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

  _collectIdsOfType(tbody, type, parentId, parentType) {
    const rows = Array.from(tbody.querySelectorAll(`tr[id^="${type}_"]`))
    const ids = []
    
    // For nested items, we need to ensure we only get items belonging to the same parent
    if (type === 'modulo') {
      // All modulos in this tbody belong to the same trilha
      rows.forEach(row => {
        const id = row.dataset.sortableId
        if (id) ids.push(id)
      })
    } else if (type === 'conteudo') {
      // Get only conteudos that belong to the same parent
      if (parentType === 'modulo') {
        // Get only conteudos that belong to the same modulo
        let currentModuloId = null
        Array.from(tbody.children).forEach(row => {
          if (row.id.startsWith('modulo_')) {
            currentModuloId = row.id.replace('modulo_', '')
          } else if (row.id.startsWith('conteudo_') && currentModuloId === parentId) {
            const id = row.dataset.sortableId
            if (id) ids.push(id)
          }
        })
      } else if (parentType === 'trilha') {
        // Get only conteudos soltos (trilha_id direto, modulo_id nil)
        rows.forEach(row => {
          if (row.dataset.parentType === 'trilha' && row.dataset.parentId === parentId) {
            const id = row.dataset.sortableId
            if (id) ids.push(id)
          }
        })
      }
    }
    
    return ids
  }
}
