import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    console.log("User menu controller connected!")
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
  }

  toggle(event) {
    console.log("Toggle clicked!")
    event.preventDefault()
    event.stopPropagation()
    
    this.dropdownTarget.classList.toggle("hidden")
    console.log("Dropdown hidden?", this.dropdownTarget.classList.contains("hidden"))
    
    if (!this.dropdownTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.closeOnClickOutside)
    } else {
      document.removeEventListener("click", this.closeOnClickOutside)
    }
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
  }
}
