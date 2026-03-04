import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "iconExpanded", "iconCollapsed", "itemLabel", "divider", "navLink"]
  static values = { collapsed: Boolean }

  connect() {
    const savedState = localStorage.getItem('sidebarCollapsed')
    if (savedState === 'true') {
      this.collapse(false)
    }
  }

  toggle(event) {
    event.preventDefault()
    if (this.collapsedValue) {
      this._hoverExpanded = false
      this.expand(true)
    } else {
      this.collapse(true)
    }
  }

  mouseEnter() {
    if (window.innerWidth < 1024) return
    if (this.collapsedValue && !this._hoverExpanded) {
      this._hoverExpanded = true
      this._visualExpand()
    }
  }

  mouseLeave() {
    if (window.innerWidth < 1024) return
    if (this._hoverExpanded) {
      this._hoverExpanded = false
      this._visualCollapse()
    }
  }

  collapse(save = true) {
    this.collapsedValue = true
    this._visualCollapse()
    if (save) localStorage.setItem('sidebarCollapsed', 'true')
  }

  expand(save = true) {
    this.collapsedValue = false
    this._visualExpand()
    if (save) localStorage.setItem('sidebarCollapsed', 'false')
  }

  _visualCollapse() {
    this.sidebarTarget.style.width = '56px'
    this.iconExpandedTarget.classList.add('hidden')
    this.iconCollapsedTarget.classList.remove('hidden')

    this.itemLabelTargets.forEach(label => label.classList.add('hidden'))
    this.dividerTargets.forEach(divider => divider.classList.add('hidden'))

    // Center icons when collapsed
    this.navLinkTargets.forEach(link => {
      link.classList.remove('gap-3', 'px-3')
      link.classList.add('justify-center', 'px-1')
    })

    this.updateMainSpacing(56)
  }

  _visualExpand() {
    this.sidebarTarget.style.width = '220px'
    this.iconExpandedTarget.classList.remove('hidden')
    this.iconCollapsedTarget.classList.add('hidden')

    this.itemLabelTargets.forEach(label => label.classList.remove('hidden'))
    this.dividerTargets.forEach(divider => divider.classList.remove('hidden'))

    // Restore padding when expanded
    this.navLinkTargets.forEach(link => {
      link.classList.add('gap-3', 'px-3')
      link.classList.remove('justify-center', 'px-1')
    })

    this.updateMainSpacing(220)
  }

  updateMainSpacing(sidebarWidth) {
    if (window.innerWidth < 1024) return

    const header = document.querySelector('[data-sidebar-spacing-target="header"]')
    const main = document.querySelector('[data-sidebar-spacing-target="main"]')

    if (header) header.style.left = `${sidebarWidth}px`
    if (main) main.style.marginLeft = `${sidebarWidth}px`
  }
}
