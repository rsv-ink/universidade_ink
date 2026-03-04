import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "dot"]
  static values  = { index: { type: Number, default: 0 }, visible: { type: Number, default: 1 } }

  connect() {
    this._currentVisible = this._computeVisible()
    this._setupInfinite()

    this._mq = window.matchMedia("(min-width: 1024px)")
    this._mqHandler = () => this._onBreakpointChange()
    this._mq.addEventListener("change", this._mqHandler)
  }

  disconnect() {
    if (this._onTransitionEnd) {
      this.trackTarget.removeEventListener("transitionend", this._onTransitionEnd)
    }
    if (this._mq && this._mqHandler) {
      this._mq.removeEventListener("change", this._mqHandler)
    }
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

  _computeVisible() {
    const css = parseInt(
      getComputedStyle(this.element).getPropertyValue("--carrossel-visible").trim()
    )
    return css > 0 ? css : Math.max(1, this.visibleValue)
  }

  _onBreakpointChange() {
    const newVisible = this._computeVisible()
    if (newVisible === this._currentVisible) return

    // Remove clones and re-setup with new visible count
    Array.from(this.trackTarget.children)
      .filter(el => el.dataset.clone)
      .forEach(el => el.remove())
    delete this.trackTarget.dataset.infiniteReady
    if (this._onTransitionEnd) {
      this.trackTarget.removeEventListener("transitionend", this._onTransitionEnd)
      this._onTransitionEnd = null
    }
    this._currentVisible = newVisible
    this.indexValue = 0
    this._setupInfinite()
  }

  _go(index, animate = true) {
    const total = this._totalSteps()
    const visible = this._currentVisible
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
    const visible = this._currentVisible
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
}
