import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "results"]

  connect() {
    this._debounce = null
    this._onOutsideClick = this._outsideClick.bind(this)
    document.addEventListener("click", this._onOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._onOutsideClick)
    clearTimeout(this._debounce)
  }

  search() {
    clearTimeout(this._debounce)
    const q = this.inputTarget.value.trim()

    if (q.length < 2) {
      this._hide()
      return
    }

    this._debounce = setTimeout(() => this._fetch(q), 300)
  }

  hideDropdown() {
    this._hide()
  }

  _fetch(q) {
    const url = `${this.element.dataset.rapidaUrl}?q=${encodeURIComponent(q)}`
    fetch(url, { headers: { Accept: "application/json" } })
      .then(r => r.json())
      .then(data => this._render(data, q))
      .catch(() => {})
  }

  _render({ trilhas, conteudos }, q) {
    const nenhum = trilhas.length === 0 && conteudos.length === 0
    let html = ""

    if (nenhum) {
      html = `<div class="px-4 py-3 text-sm text-gray-500">Nenhum resultado para "<strong>${this._esc(q)}</strong>"</div>`
    } else {
      if (trilhas.length > 0) {
        html += `<p class="px-4 pt-2 pb-1 text-xs font-semibold text-gray-400 uppercase tracking-wide">Trilhas</p>`
        trilhas.forEach(t => {
          html += `<a href="${t.url}" class="flex items-center gap-3 px-4 py-2 hover:bg-gray-50 transition-colors">
            <svg class="w-4 h-4 text-pink-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
            </svg>
            <span class="text-sm text-gray-700 truncate">${this._esc(t.titulo)}</span>
          </a>`
        })
      }

      if (conteudos.length > 0) {
        const sep = trilhas.length > 0 ? "border-t border-gray-100 mt-1" : ""
        html += `<p class="px-4 pt-2 pb-1 text-xs font-semibold text-gray-400 uppercase tracking-wide ${sep}">Conteúdos</p>`
        conteudos.forEach(c => {
          html += `<a href="${c.url}" class="flex items-start gap-3 px-4 py-2 hover:bg-gray-50 transition-colors">
            <svg class="w-4 h-4 text-teal-400 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
            <div class="min-w-0">
              <p class="text-sm text-gray-700 truncate">${this._esc(c.titulo)}</p>
              ${c.categoria ? `<p class="text-xs text-gray-400">${this._esc(c.categoria)}</p>` : ""}
            </div>
          </a>`
        })
      }
    }

    const buscaUrl = `${this.element.dataset.buscaUrl}?q=${encodeURIComponent(q)}`
    html += `<div class="border-t border-gray-100 px-4 py-2 mt-1">
      <a href="${buscaUrl}" class="text-xs text-pink-600 hover:text-pink-700 font-medium">
        Ver todos os resultados para "${this._esc(q)}" →
      </a>
    </div>`

    this.resultsTarget.innerHTML = html
    this._show()
  }

  _show() { this.dropdownTarget.classList.remove("hidden") }
  _hide() { this.dropdownTarget.classList.add("hidden") }

  _outsideClick(e) {
    if (!this.element.contains(e.target)) this._hide()
  }

  _esc(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }
}
