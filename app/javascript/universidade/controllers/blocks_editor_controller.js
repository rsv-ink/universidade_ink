import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

const BLOCK_TYPES = {
  titulo:  { label: "Título",  icon: "T" },
  texto:   { label: "Texto",   icon: "¶" },
  citacao: { label: "Citação", icon: "\u201C" },
  codigo:  { label: "Código",  icon: "</>" },
  tabela:  { label: "Tabela",  icon: "⊞" },
  imagem:  { label: "Imagem",  icon: "▣" },
  video:   { label: "Vídeo",   icon: "▶" },
}

export default class extends Controller {
  static targets = ["canvas", "palette", "hidden", "emptyState"]
  static values  = { uploadUrl: String }

  connect() {
    this._setupSortable()
    this._loadInitialContent()
    const form = this.element.closest("form")
    if (form) form.addEventListener("submit", this._serialize.bind(this))
  }

  disconnect() {
    if (this._canvasSortable) this._canvasSortable.destroy()
    if (this._paletteSortable) this._paletteSortable.destroy()
  }

  // ── Sortable setup ───────────────────────────────────────────────────

  _setupSortable() {
    this._paletteSortable = Sortable.create(this.paletteTarget, {
      group:     { name: "blocks", pull: "clone", put: false },
      sort:      false,
      animation: 150,
    })

    this._canvasSortable = Sortable.create(this.canvasTarget, {
      group:      { name: "blocks", pull: false, put: true },
      animation:  150,
      handle:     ".block-drag-handle",
      ghostClass: "block-ghost",
      onAdd: (event) => {
        const type = event.item.dataset.blockType
        if (!type || !BLOCK_TYPES[type]) { event.item.remove(); return }
        const blockEl = this._createBlockElement(type, this._uid(), {})
        this.canvasTarget.insertBefore(blockEl, event.item)
        event.item.remove()
        this._updateEmptyState()
        this._focusFirstInput(blockEl)
      },
    })
  }

  // ── Block creation ───────────────────────────────────────────────────

  _uid() {
    if (typeof crypto !== "undefined" && crypto.randomUUID) return crypto.randomUUID()
    return `b${Date.now()}${Math.random().toString(36).slice(2, 9)}`
  }

  _createBlockElement(type, id, data) {
    const el = document.createElement("div")
    el.className = "block-item"
    el.dataset.blockId   = id
    el.dataset.blockType = type
    el.innerHTML = this._blockHtml(type, id, data)
    return el
  }

  _blockHtml(type, id, data) {
    const info = BLOCK_TYPES[type] || { label: type, icon: "?" }
    return `
      <div class="block-controls-overlay">
        <div class="block-drag-handle" title="Arrastar bloco">
          <svg width="12" height="12" viewBox="0 0 16 16" fill="currentColor">
            <path d="M4 4h2v2H4V4zm0 4h2v2H4V8zm0 4h2v2H4v-2zm6-8h2v2h-2V4zm0 4h2v2h-2V8zm0 4h2v2h-2v-2z" fill="#9ca3af"/>
          </svg>
        </div>
        <button type="button" class="block-delete-btn"
                data-action="click->blocks-editor#deleteBlock"
                title="Remover bloco">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 6L6 18M6 6l12 12"></path>
          </svg>
        </button>
      </div>
      <div class="block-body">
        ${this._editorHtml(type, id, data)}
      </div>
    `
  }

  _editorHtml(type, id, data) {
    const e = (s) => String(s ?? "")
      .replace(/&/g, "&amp;").replace(/"/g, "&quot;")
      .replace(/</g, "&lt;").replace(/>/g, "&gt;")

    switch (type) {
      case "titulo":
        return `
          <input type="text" class="block-field-titulo"
                 placeholder="Título..."
                 value="${e(data.text)}"
                 data-field="text" />`

      case "texto":
        return `
          <div class="block-field-texto"
               contenteditable="true"
               data-field="html"
               data-placeholder="Digite o texto aqui...">${data.html || ""}</div>`

      case "citacao":
        return `
          <div class="block-field-citacao-text"
               contenteditable="true"
               data-field="text"
               data-placeholder="Texto da citação...">${data.text || ""}</div>
          <input type="text" class="block-field-citacao-caption"
                 placeholder="Fonte ou autor (opcional)"
                 value="${e(data.caption)}"
                 data-field="caption" />`

      case "codigo":
        return `
          <textarea class="block-field-codigo"
                    placeholder="// código aqui..."
                    data-field="code"
                    rows="1"
                    data-action="input->blocks-editor#autoResize focus->blocks-editor#autoResize"
                    style="height: auto; overflow-y: hidden;">${e(data.code)}</textarea>`

      case "tabela": {
        const rows = Array.isArray(data.rows) && data.rows.length >= 2
          ? data.rows
          : [["", ""], ["", ""]]
        return `
          <div class="block-tabela-scroll">
            <table class="block-edit-tabela" data-field="rows">
              ${rows.map((row, ri) => `
                <tr>
                  ${row.map((cell) => `
                    <td>
                      <div contenteditable="true"
                           class="block-tabela-cell ${ri === 0 ? "block-tabela-cell--header" : ""}">${e(cell)}</div>
                    </td>`).join("")}
                  <td class="block-tabela-actions-cell">
                    <button type="button" class="block-tabela-del-row"
                            data-action="click->blocks-editor#removeTableRow"
                            title="Remover linha">−</button>
                  </td>
                </tr>`).join("")}
            </table>
          </div>
          <div class="block-tabela-footer">
            <button type="button" class="block-tabela-add-row"
                    data-action="click->blocks-editor#addTableRow">+ Linha</button>
            <button type="button" class="block-tabela-add-col"
                    data-action="click->blocks-editor#addTableCol">+ Coluna</button>
          </div>`
      }

      case "imagem":
        return `
          <div class="block-media-editor">
            <div class="block-media-url-row">
              <input type="text" class="block-field-url"
                     placeholder="URL da imagem..."
                     value="${e(data.url)}"
                     data-field="url"
                     data-action="input->blocks-editor#previewImage" />
              <input type="text" class="block-field-alt"
                     placeholder="Texto alternativo (acessibilidade)"
                     value="${e(data.alt)}"
                     data-field="alt" />
            </div>
            ${data.url
              ? `<img class="block-media-preview" src="${e(data.url)}" alt="${e(data.alt)}" />`
              : `<div class="block-media-placeholder">Nenhuma imagem inserida</div>`}
          </div>`

      case "video": {
        const embedUrl = data.embedUrl || this._parseVideoUrl(data.url || "")
        return `
          <div class="block-media-editor">
            <input type="text" class="block-field-url"
                   placeholder="Link do YouTube ou Vimeo..."
                   value="${e(data.url)}"
                   data-field="url"
                   data-action="input->blocks-editor#previewVideo" />
            <input type="hidden" data-field="embedUrl" value="${e(embedUrl)}" />
            ${embedUrl
              ? `<iframe class="block-media-preview block-media-preview--video" src="${e(embedUrl)}" allowfullscreen></iframe>`
              : `<div class="block-media-placeholder">Cole o link para visualizar</div>`}
          </div>`
      }

      default:
        return `<p style="color:#9ca3af;font-size:0.875rem;">Tipo desconhecido: ${type}</p>`
    }
  }

  _listItemHtml(style, index, text) {
    const bullet = style === "ordered" ? `${index + 1}.` : "•"
    const e = (s) => String(s ?? "").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    return `
      <div class="block-lista-item">
        <span class="block-lista-bullet">${bullet}</span>
        <div contenteditable="true" class="block-lista-item-text">${e(text)}</div>
        <button type="button" class="block-lista-del-item"
                data-action="click->blocks-editor#removeListItem"
                title="Remover item">−</button>
      </div>`
  }

  // ── Actions ──────────────────────────────────────────────────────────

  deleteBlock(event) {
    event.target.closest(".block-item")?.remove()
    this._updateEmptyState()
  }

  addListItem(event) {
    const blockEl   = event.target.closest(".block-item")
    const container = blockEl.querySelector("[data-field='items']")
    const checked   = blockEl.querySelector("[data-field='style']:checked")
    const style     = checked ? checked.value : "unordered"
    const count     = container.querySelectorAll(".block-lista-item").length
    const div       = document.createElement("div")
    div.innerHTML   = this._listItemHtml(style, count, "")
    const item = div.firstElementChild
    container.appendChild(item)
    item.querySelector(".block-lista-item-text").focus()
  }

  removeListItem(event) {
    const item      = event.target.closest(".block-lista-item")
    const container = item.closest("[data-field='items']")
    if (container.querySelectorAll(".block-lista-item").length > 1) item.remove()
  }

  updateListBullets(event) {
    const blockEl = event.target.closest(".block-item")
    const style   = event.target.value
    blockEl.querySelectorAll(".block-lista-item").forEach((item, i) => {
      item.querySelector(".block-lista-bullet").textContent =
        style === "ordered" ? `${i + 1}.` : "•"
    })
  }

  addTableRow(event) {
    const blockEl  = event.target.closest(".block-item")
    const table    = blockEl.querySelector(".block-edit-tabela")
    const colCount = table.rows[0] ? table.rows[0].cells.length - 1 : 2
    const tr       = table.insertRow()
    for (let i = 0; i < colCount; i++) {
      const td = tr.insertCell()
      td.innerHTML = `<div contenteditable="true" class="block-tabela-cell"></div>`
    }
    const actionsTd = tr.insertCell()
    actionsTd.className = "block-tabela-actions-cell"
    actionsTd.innerHTML = `<button type="button" class="block-tabela-del-row"
      data-action="click->blocks-editor#removeTableRow" title="Remover linha">−</button>`
  }

  removeTableRow(event) {
    const tr    = event.target.closest("tr")
    const table = tr.closest("table")
    if (table.rows.length > 1) tr.remove()
  }

  addTableCol(event) {
    const blockEl = event.target.closest(".block-item")
    const table   = blockEl.querySelector(".block-edit-tabela")
    Array.from(table.rows).forEach((row, ri) => {
      const actionsTd = row.querySelector(".block-tabela-actions-cell")
      const td = document.createElement("td")
      td.innerHTML = `<div contenteditable="true"
        class="block-tabela-cell ${ri === 0 ? "block-tabela-cell--header" : ""}"></div>`
      row.insertBefore(td, actionsTd)
    })
  }

  previewImage(event) {
    const blockEl = event.target.closest(".block-item")
    const url     = event.target.value.trim()
    this._replacePreview(blockEl,
      url
        ? `<img class="block-media-preview" src="${url}" alt="" />`
        : `<div class="block-media-placeholder">Nenhuma imagem inserida</div>`)
  }

  previewVideo(event) {
    const blockEl = event.target.closest(".block-item")
    const url     = event.target.value.trim()
    const embed   = this._parseVideoUrl(url)
    blockEl.querySelector("[data-field='embedUrl']").value = embed || ""
    this._replacePreview(blockEl,
      embed
        ? `<iframe class="block-media-preview block-media-preview--video" src="${embed}" allowfullscreen></iframe>`
        : `<div class="block-media-placeholder">Cole o link para visualizar</div>`)
  }

  // ── Serialization ────────────────────────────────────────────────────

  _serialize(event) {
    if (event) event.preventDefault()
    const blocks = []
    this.canvasTarget.querySelectorAll(":scope > .block-item").forEach(blockEl => {
      const type = blockEl.dataset.blockType
      const id   = blockEl.dataset.blockId
      blocks.push({ id, type, data: this._extractData(type, blockEl) })
    })
    this.hiddenTarget.value = JSON.stringify(blocks)
    if (event) event.target.submit()
  }

  _extractData(type, el) {
    const val  = (sel) => el.querySelector(sel)?.value?.trim() ?? ""
    const html = (sel) => el.querySelector(sel)?.innerHTML?.trim() ?? ""

    switch (type) {
      case "titulo":  return { text: val("[data-field='text']") }
      case "texto":   return { html: html("[data-field='html']") }
      case "citacao": return { text: html("[data-field='text']"), caption: val("[data-field='caption']") }

      case "lista": {
        const checked = el.querySelector("[data-field='style']:checked")
        const style   = checked ? checked.value : "unordered"
        const items   = [...el.querySelectorAll(".block-lista-item-text")]
          .map(d => d.textContent.trim())
        return { style, items }
      }

      case "codigo":  return { code: val("[data-field='code']") }

      case "tabela": {
        const table = el.querySelector(".block-edit-tabela")
        const rows  = [...table.rows].map(row =>
          [...row.cells]
            .filter(td => !td.classList.contains("block-tabela-actions-cell"))
            .map(td => td.querySelector("[contenteditable]")?.textContent.trim() ?? "")
        )
        return { rows }
      }

      case "imagem":  return { url: val("[data-field='url']"), alt: val("[data-field='alt']") }
      case "video":   return { url: val("[data-field='url']"), embedUrl: val("[data-field='embedUrl']") }
      default:        return {}
    }
  }

  // ── Initial content ──────────────────────────────────────────────────

  _loadInitialContent() {
    const raw = (this.hiddenTarget.value || "").trim()
    if (!raw) { this._updateEmptyState(); return }

    let blocks = null
    try {
      const parsed = JSON.parse(raw)
      if (Array.isArray(parsed)) blocks = parsed
    } catch (_) { /* legacy HTML */ }

    if (!blocks) {
      blocks = [{ id: this._uid(), type: "texto", data: { html: raw } }]
    }

    blocks.forEach(b => {
      if (!b.type) return
      this.canvasTarget.appendChild(
        this._createBlockElement(b.type, b.id || this._uid(), b.data || {})
      )
    })

    this._updateEmptyState()
    // Auto-resize all textareas initially
    this.canvasTarget.querySelectorAll("textarea").forEach(t => this.autoResize(t))
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  // Called via data-action="input->blocks-editor#autoResize" or manually
  autoResize(event) {
    const el = event.target || event
    if (!el || el.tagName !== "TEXTAREA") return
    el.style.height = "auto"
    el.style.height = el.scrollHeight + "px"
  }

  _updateEmptyState() {
    if (!this.hasEmptyStateTarget) return
    const hasBlocks = !!this.canvasTarget.querySelector(":scope > .block-item")
    this.emptyStateTarget.style.display = hasBlocks ? "none" : "flex"
  }

  _focusFirstInput(blockEl) {
    const input = blockEl.querySelector("input[type='text'], [contenteditable='true'], textarea")
    if (!input) return
    setTimeout(() => {
      input.focus()
      if (input.isContentEditable) {
        const range = document.createRange()
        range.selectNodeContents(input)
        range.collapse(false)
        const sel = window.getSelection()
        sel.removeAllRanges()
        sel.addRange(range)
      }
    }, 30)
  }

  _replacePreview(blockEl, html) {
    const old = blockEl.querySelector(".block-media-preview, .block-media-placeholder")
    if (!old) return
    const div = document.createElement("div")
    div.innerHTML = html
    old.replaceWith(div.firstElementChild)
  }

  _parseVideoUrl(url) {
    if (!url) return null
    const yt    = url.match(/(?:youtube\.com\/watch\?(?:.*&)?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
    const vimeo = url.match(/vimeo\.com\/(\d+)/)
    if (yt)    return `https://www.youtube.com/embed/${yt[1]}`
    if (vimeo) return `https://player.vimeo.com/video/${vimeo[1]}`
    return null
  }
}
