import { Controller } from "@hotwired/stimulus"

// Manages the active-state highlight for sidebar course items.
// When a link is clicked (Turbo Frame navigation), Stimulus updates
// the data-sidebar-active attribute so CSS can apply the highlight.
export default class extends Controller {
  select(event) {
    // Remove active from all links in sidebar
    this.element.querySelectorAll("[data-sidebar-active]")
      .forEach(el => el.removeAttribute("data-sidebar-active"))

    // Mark the clicked link as active
    event.currentTarget.dataset.sidebarActive = "true"
  }
}
