import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "dot"]
  static values  = { index: { type: Number, default: 0 }, visible: { type: Number, default: 1 } }

  connect() {
    this._setupInfinite()
  }

  prev() {
    if (this._totalSteps() <= 1) return
    this._go(this.indexValue - 1)
  }

  next() {
    if (this._totalSteps() <= 1) return
    this._go(this.indexValue + 1)
  }

  dot(event) {
    this._go(parseInt(event.currentTarget.dataset.index) || 0)
  }

  _go(index, animate = true) {
    const total = this._totalSteps()
    const visible = Math.max(1, this.visibleValue)
    const stepPercent = 100 / visible
    const offset = this._offset || 0
    const normalized = ((index % total) + total) % total
    this.indexValue = index
    this.trackTarget.style.transition = animate ? "transform 0.35s ease" : "none"
    this.trackTarget.style.transform = `translateX(-${(index + offset) * stepPercent}%)`
    this.dotTargets.forEach((d, i) => d.classList.toggle("active", i === normalized))
  }

  _totalSteps() {
    return this._totalOriginal || this.trackTarget.children.length
  }

  _setupInfinite() {
    const visible = Math.max(1, this.visibleValue)
    const slides = Array.from(this.trackTarget.children).filter(
      (el) => !el.dataset.clone
    )

    this._totalOriginal = slides.length
    if (this._totalOriginal <= visible || this.trackTarget.dataset.infiniteReady) {
      this._offset = 0
      this._go(0, false)
      return
    }

    const headClones = slides.slice(0, visible).map((slide) => {
      const clone = slide.cloneNode(true)
      clone.dataset.clone = "true"
      return clone
    })

    const tailClones = slides.slice(-visible).map((slide) => {
      const clone = slide.cloneNode(true)
      clone.dataset.clone = "true"
      return clone
    })

    tailClones.reverse().forEach((clone) => {
      this.trackTarget.insertBefore(clone, this.trackTarget.firstChild)
    })

    headClones.forEach((clone) => {
      this.trackTarget.appendChild(clone)
    })

    this._offset = visible
    this.trackTarget.dataset.infiniteReady = "true"

    this._go(0, false)

    this._onTransitionEnd = () => {
      const total = this._totalSteps()
      if (this.indexValue >= total) {
        this._go(0, false)
      } else if (this.indexValue < 0) {
        this._go(total - 1, false)
      }
    }

    this.trackTarget.addEventListener("transitionend", this._onTransitionEnd)
  }

  disconnect() {
    if (this._onTransitionEnd) {
      this.trackTarget.removeEventListener("transitionend", this._onTransitionEnd)
    }
  }
}
