import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "main"]

  connect() {
    if (window.innerWidth < 1024) return

    const savedState = localStorage.getItem('sidebarCollapsed')
    const sidebarWidth = savedState === 'true' ? 56 : 220

    // Only apply spacing if desktop sidebar exists
    const sidebar = document.querySelector('[data-sidebar-toggle-target="sidebar"]')
    if (sidebar) {
      this.updateSpacing(sidebarWidth)
    }

    window.addEventListener('resize', this._onResize.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this._onResize.bind(this))
  }

  _onResize() {
    if (window.innerWidth >= 1024) {
      const sidebar = document.querySelector('[data-sidebar-toggle-target="sidebar"]')
      if (sidebar) {
        const currentState = localStorage.getItem('sidebarCollapsed')
        const width = currentState === 'true' ? 56 : 220
        this.updateSpacing(width)
      }
    } else {
      this.resetSpacing()
    }
  }

  updateSpacing(sidebarWidth) {
    if (this.hasHeaderTarget) {
      this.headerTarget.style.left = `${sidebarWidth}px`
    }
    if (this.hasMainTarget) {
      this.mainTarget.style.marginLeft = `${sidebarWidth}px`
    }
  }

  resetSpacing() {
    if (this.hasHeaderTarget) {
      this.headerTarget.style.left = '0px'
    }
    if (this.hasMainTarget) {
      this.mainTarget.style.marginLeft = ''
    }
  }
}
