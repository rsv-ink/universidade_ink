import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values  = {
    open:  { type: Boolean, default: false },
    group: { type: String, default: null },
    openChildren: { type: String, default: null }
  }

  toggle() {
    const willOpen = !this.openValue
    if (willOpen) this._closeOtherAccordions()
    this.openValue = willOpen
  }

  openValueChanged() {
    if (this.hasContentTarget) {
      this.contentTargets.forEach(t => t.classList.toggle("hidden", !this.openValue))
    }
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = this.openValue ? "rotate(180deg)" : "rotate(0deg)"
    }
    if (this.openValue && this.openChildrenValue) {
      this._openChildAccordions(this.openChildrenValue)
    }
  }

  _closeOtherAccordions() {
    const all = document.querySelectorAll('[data-controller~="accordion"]')
    all.forEach((element) => {
      if (element === this.element) return
      const controller = this.application.getControllerForElementAndIdentifier(element, "accordion")
      if (!controller) return

      const sameGroup = this.groupValue
        ? controller.groupValue === this.groupValue
        : !controller.groupValue

      if (sameGroup) controller.openValue = false
    })
  }

  _openChildAccordions(groupName) {
    const nested = this.element.querySelectorAll('[data-controller~="accordion"]')
    nested.forEach((element) => {
      if (element === this.element) return
      const controller = this.application.getControllerForElementAndIdentifier(element, "accordion")
      if (!controller) return
      if (controller.groupValue === groupName) controller.openValue = true
    })
  }
}
