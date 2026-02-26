import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "dot"]
  static values  = { index: { type: Number, default: 0 } }

  prev() {
    const total = this.trackTarget.children.length
    this._go((this.indexValue - 1 + total) % total)
  }

  next() {
    const total = this.trackTarget.children.length
    this._go((this.indexValue + 1) % total)
  }

  dot(event) {
    this._go(parseInt(event.currentTarget.dataset.index) || 0)
  }

  _go(index) {
    this.indexValue = index
    this.trackTarget.style.transform = `translateX(-${index * 100}%)`
    this.dotTargets.forEach((d, i) => d.classList.toggle("active", i === index))
  }
}
