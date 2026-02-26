import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

const BLOCK_TYPES = {
  titulo:   { label: "Título",   icon: "T" },
  texto:    { label: "Texto",    icon: "¶" },
  citacao:  { label: "Citação",  icon: "\u201C" },
  codigo:   { label: "Código",   icon: "</>" },
  imagem:   { label: "Imagem",   icon: "▣" },
  video:    { label: "Vídeo",    icon: "▶" },
  divisor:  { label: "Divisor",  icon: "—" },
  destaque: { label: "Destaque", icon: "◈" },
}

const DESTAQUE_COLORS = [
  { value: "#fef9c3", label: "Amarelo" },
  { value: "#dbeafe", label: "Azul" },
  { value: "#dcfce7", label: "Verde" },
  { value: "#fce7f3", label: "Rosa" },
  { value: "#ffedd5", label: "Laranja" },
  { value: "#f3e8ff", label: "Roxo" },
]

const TOOLBAR_COLORS = [
  "#111827", "#ef4444", "#f97316", "#eab308",
  "#22c55e", "#3b82f6", "#8b5cf6", "#ec4899", "#6b7280"
]

export default class extends Controller {
  static targets = ["canvas", "palette", "hidden", "emptyState"]
  static values  = { uploadUrl: String }

  connect() {
    this._setupSortable()
    this._loadInitialContent()
    const form = this.element.closest("form")
    if (form) form.addEventListener("submit", this._serialize.bind(this))

    this._toolbar = this._buildToolbar()
    document.body.appendChild(this._toolbar)

    this._onSelectionChange = this._handleSelectionChange.bind(this)
    this._onDocClick        = this._handleDocClick.bind(this)
    this._onDocKeydown      = this._handleDocKeydown.bind(this)
    this._onPaste           = this._handlePaste.bind(this)
    document.addEventListener("selectionchange", this._onSelectionChange)
    document.addEventListener("click",           this._onDocClick)
    document.addEventListener("keydown",         this._onDocKeydown)
    this.canvasTarget.addEventListener("paste",  this._onPaste)
  }

  disconnect() {
    if (this._canvasSortable) this._canvasSortable.destroy()
    if (this._paletteSortable) this._paletteSortable.destroy()
    if (this._toolbar) this._toolbar.remove()
    document.removeEventListener("selectionchange", this._onSelectionChange)
    document.removeEventListener("click",           this._onDocClick)
    document.removeEventListener("keydown",         this._onDocKeydown)
    if (this.hasCanvasTarget) this.canvasTarget.removeEventListener("paste", this._onPaste)
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
      case "titulo": {
        const level = [1, 2, 3, 4].includes(data.level) ? data.level : 2
        const levelBtns = [1, 2, 3, 4].map(l =>
          `<button type="button" class="titulo-level-btn${l === level ? " active" : ""}" data-level="${l}">H${l}</button>`
        ).join("")
        return `
          <div class="block-titulo-wrapper">
            <div class="block-titulo-levels"
                 data-action="mousedown->blocks-editor#changeTitleLevel">
              ${levelBtns}
            </div>
            <h${level} class="block-field-titulo"
               contenteditable="true"
               data-field="text"
               data-level="${level}"
               data-placeholder="Título..."
              data-action="keydown->blocks-editor#titleKeydown">${e(data.text)}</h${level}>
          </div>`
      }

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

      case "imagem": {
        // Migrate old format { url, alt } → new format { layout, images }
        const imgData = (data.images && Array.isArray(data.images))
          ? data
          : { layout: "galeria", images: data.url ? [{ url: data.url, alt: data.alt || "" }] : [] }

        const layout = imgData.layout === "carrossel" ? "carrossel" : "galeria"
        const images = Array.isArray(imgData.images) ? imgData.images : []

        const gridItemsHtml = images
          .filter(img => img.url)
          .map(img => this._imageGridItemHtml(img.url))
          .join("")

        const dimsHint = layout === "carrossel"
          ? "Proporção ideal: 16:9 — ex: 1280 × 720 px"
          : "Proporção ideal: 4:3 — ex: 1200 × 900 px"

        return `
          <div class="imagem-editor" data-layout="${layout}">
            <div class="imagem-controls">
              <div class="imagem-toggle-group">
                <button type="button"
                        class="imagem-toggle-btn${layout === "carrossel" ? " active" : ""}"
                        data-action="click->blocks-editor#changeImageLayout"
                        data-layout="carrossel">⟵ Carrossel ⟶</button>
                <button type="button"
                        class="imagem-toggle-btn${layout === "galeria" ? " active" : ""}"
                        data-action="click->blocks-editor#changeImageLayout"
                        data-layout="galeria">⊞ Galeria</button>
              </div>
            </div>
            <div class="imagem-dropzone"
                 data-action="click->blocks-editor#triggerDropzoneClick dragover->blocks-editor#dragoverDropzone dragleave->blocks-editor#dragleaveDropzone drop->blocks-editor#dropImages">
              <input type="file" accept="image/*" multiple hidden class="imagem-dropzone-input"
                     data-action="change->blocks-editor#uploadImageFiles" />
              <span class="imagem-dropzone-icon">↑</span>
              <span class="imagem-dropzone-text">Clique ou arraste imagens aqui</span>
              <span class="imagem-dropzone-hint">${dimsHint}</span>
            </div>
            <div class="imagem-grid" data-field="images">${gridItemsHtml}</div>
            <div class="imagem-preview-area"></div>
          </div>`
      }

      case "video": {
        const embedUrl = data.embedUrl || this._parseVideoUrl(data.url || "")
        return `
          <div class="block-media-editor">
            <div class="block-video-edit-overlay"></div>
            <input type="text" class="block-field-url"
                   placeholder="Link do YouTube ou Vimeo..."
                   value="${e(data.url)}"
                   data-field="url"
                   data-action="input->blocks-editor#previewVideo" />
            <input type="hidden" data-field="embedUrl" value="${e(embedUrl)}" />
            <div class="block-media-preview-slot"></div>
          </div>`
      }

      case "divisor":
        return `<div class="divisor-editor"></div>`

      case "destaque": {
        const color = data.color || "#fef9c3"
        const swatches = DESTAQUE_COLORS.map(c =>
          `<button type="button" class="destaque-swatch${c.value === color ? " active" : ""}"
                   style="background:${c.value}"
                   data-color="${c.value}"
                   data-action="mousedown->blocks-editor#changeDestaqueColor"
                   title="${c.label}"></button>`
        ).join("")
        return `
          <div class="destaque-wrapper">
            <div class="destaque-swatches">${swatches}</div>
            <div class="destaque-editor" style="background-color:${color}" data-color="${color}">
              <div class="block-field-destaque"
                   contenteditable="true"
                   data-field="text"
                   data-placeholder="Texto de destaque...">${data.text || ""}</div>
            </div>
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


  // ── Image block actions ─────────────────────────────────────────────

  changeImageLayout(event) {
    const blockEl = event.target.closest(".block-item")
    const editor  = blockEl.querySelector(".imagem-editor")
    const layout  = event.target.dataset.layout
    if (!layout) return
    editor.dataset.layout = layout
    event.target.closest(".imagem-toggle-group")
      .querySelectorAll(".imagem-toggle-btn")
      .forEach(b => b.classList.toggle("active", b.dataset.layout === layout))
    const hint = blockEl.querySelector(".imagem-dropzone-hint")
    if (hint) hint.textContent = layout === "carrossel"
      ? "Proporção ideal: 16:9 — ex: 1280 × 720 px"
      : "Proporção ideal: 4:3 — ex: 1200 × 900 px"
    this._refreshImagePreview(blockEl)
  }

  triggerDropzoneClick(event) {
    // Ignore clicks on the remove buttons inside the grid
    if (event.target.closest(".imagem-grid-remove")) return
    event.currentTarget.querySelector(".imagem-dropzone-input")?.click()
  }

  dragoverDropzone(event) {
    event.preventDefault()
    event.currentTarget.classList.add("imagem-dropzone--active")
  }

  dragleaveDropzone(event) {
    event.currentTarget.classList.remove("imagem-dropzone--active")
  }

  async dropImages(event) {
    event.preventDefault()
    const dropzone = event.currentTarget
    dropzone.classList.remove("imagem-dropzone--active")
    const files = [...(event.dataTransfer?.files || [])].filter(f => f.type.startsWith("image/"))
    if (!files.length) return
    await this._uploadFiles(files, dropzone.closest(".block-item"))
  }

  async uploadImageFiles(event) {
    const files = [...(event.target.files || [])]
    if (!files.length) return
    const blockEl = event.target.closest(".block-item")
    event.target.value = ""
    await this._uploadFiles(files, blockEl)
  }

  removeImageGridItem(event) {
    event.stopPropagation()
    const item    = event.target.closest(".imagem-grid-item")
    const blockEl = event.target.closest(".block-item")
    item?.remove()
    this._refreshImagePreview(blockEl)
  }

  async _uploadFiles(files, blockEl) {
    const hint    = blockEl.querySelector(".imagem-dropzone-hint")
    const origTxt = hint?.textContent || "Múltiplos arquivos suportados"
    if (hint) hint.textContent = `Enviando ${files.length} arquivo(s)...`

    const results = await Promise.allSettled(files.map(f => this._uploadSingleFile(f)))

    const grid = blockEl.querySelector(".imagem-grid")
    results.forEach((result, i) => {
      if (result.status === "fulfilled" && result.value) {
        const div = document.createElement("div")
        div.innerHTML = this._imageGridItemHtml(result.value)
        grid.appendChild(div.firstElementChild)
      } else {
        console.error("[upload] Falha ao enviar:", files[i]?.name, result.reason)
      }
    })

    if (hint) hint.textContent = origTxt
    this._initImageGridSortable(blockEl)
    this._refreshImagePreview(blockEl)
  }

  async _uploadSingleFile(file) {
    const fd = new FormData()
    fd.append("image", file)
    const resp = await fetch(this.uploadUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" },
      body: fd,
    })
    const json = await resp.json()
    if (!json.url) throw new Error(json.error || "Erro desconhecido")
    return json.url
  }

  _imageGridItemHtml(url) {
    const e = (s) => String(s ?? "").replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    return `
      <div class="imagem-grid-item" data-url="${e(url)}">
        <img src="${e(url)}" alt="" loading="lazy" />
        <button type="button" class="imagem-grid-remove"
                data-action="click->blocks-editor#removeImageGridItem"
                title="Remover imagem">×</button>
      </div>`
  }

  _initImageGridSortable(blockEl) {
    const grid = blockEl.querySelector(".imagem-grid")
    if (!grid) return
    if (grid._sortable) { grid._sortable.destroy(); grid._sortable = null }
    if (grid.children.length < 2) return
    grid._sortable = Sortable.create(grid, {
      animation: 150,
      onEnd: () => this._refreshImagePreview(blockEl),
    })
  }

  _refreshImagePreview(blockEl) {
    const editor = blockEl.querySelector(".imagem-editor")
    const area   = blockEl.querySelector(".imagem-preview-area")
    if (!editor || !area) return

    const layout = editor.dataset.layout || "galeria"
    const images = [...blockEl.querySelectorAll(".imagem-grid-item")]
      .map(item => ({ url: item.dataset.url || "", alt: "" }))
      .filter(i => i.url)

    if (images.length === 0) { area.innerHTML = ""; return }

    area.innerHTML = layout === "carrossel"
      ? this._buildCarouselHtml(images)
      : this._buildGalleryHtml(images)
  }

  carouselPrev(event) {
    const wrap = event.target.closest(".imagem-carrossel")
    if (!wrap) return
    const total = wrap.querySelectorAll(".carrossel-slide").length
    const idx   = ((parseInt(wrap.dataset.carouselIndex) || 0) - 1 + total) % total
    this._goToSlide(wrap, idx)
  }

  carouselNext(event) {
    const wrap  = event.target.closest(".imagem-carrossel")
    if (!wrap) return
    const total = wrap.querySelectorAll(".carrossel-slide").length
    const idx   = ((parseInt(wrap.dataset.carouselIndex) || 0) + 1) % total
    this._goToSlide(wrap, idx)
  }

  carouselDot(event) {
    const wrap = event.target.closest(".imagem-carrossel")
    if (!wrap) return
    this._goToSlide(wrap, parseInt(event.target.dataset.index) || 0)
  }

  _goToSlide(wrap, index) {
    wrap.dataset.carouselIndex = index
    wrap.querySelector(".carrossel-track").style.transform = `translateX(-${index * 100}%)`
    wrap.querySelectorAll(".carrossel-dot").forEach((d, i) => d.classList.toggle("active", i === index))
  }

  _buildCarouselHtml(images) {
    const slides = images.map(img =>
      `<div class="carrossel-slide"><img src="${img.url}" alt="${img.alt}" loading="lazy" /></div>`
    ).join("")
    const dots = images.map((_, i) =>
      `<button type="button" class="carrossel-dot${i === 0 ? " active" : ""}"
               data-index="${i}"
               data-action="click->blocks-editor#carouselDot"></button>`
    ).join("")
    return `
      <div class="imagem-carrossel" data-carousel-index="0">
        <div class="carrossel-viewport">
          <div class="carrossel-track">${slides}</div>
        </div>
        ${images.length > 1 ? `
          <button type="button" class="carrossel-btn carrossel-btn-prev"
                  data-action="click->blocks-editor#carouselPrev">‹</button>
          <button type="button" class="carrossel-btn carrossel-btn-next"
                  data-action="click->blocks-editor#carouselNext">›</button>
          <div class="carrossel-dots">${dots}</div>` : ""}
      </div>`
  }

  _buildGalleryHtml(images) {
    const imgs = images.map(img =>
      `<img src="${img.url}" alt="${img.alt}" loading="lazy" />`
    ).join("")
    return `<div class="imagem-galeria">${imgs}</div>`
  }

  // ── Destaque block actions ────────────────────────────────────────────

  changeDestaqueColor(event) {
    event.preventDefault() // keep focus on the contenteditable
    const btn     = event.target.closest("[data-color]")
    if (!btn) return
    const color   = btn.dataset.color
    const blockEl = btn.closest(".block-item")
    const editor  = blockEl.querySelector(".destaque-editor")
    if (!editor) return
    editor.style.backgroundColor = color
    editor.dataset.color = color
    blockEl.querySelectorAll(".destaque-swatch")
      .forEach(s => s.classList.toggle("active", s.dataset.color === color))
  }

  previewVideo(event) {
    const blockEl = event.target.closest(".block-item")
    const url     = event.target.value.trim()
    const embed   = this._parseVideoUrl(url)
    blockEl.querySelector("[data-field='embedUrl']").value = embed || ""
  }

  // ── Title block actions ──────────────────────────────────────────────

  changeTitleLevel(event) {
    const btn = event.target.closest("[data-level]")
    if (!btn) return
    event.preventDefault() // keep focus on the heading

    const level   = parseInt(btn.dataset.level)
    const blockEl = event.target.closest(".block-item")
    const wrapper = blockEl.querySelector(".block-titulo-wrapper")
    const oldH    = wrapper.querySelector("[data-field='text']")

    // Create new heading element at the correct level
    const newH = document.createElement(`h${level}`)
    newH.className           = oldH.className
    newH.contentEditable     = "true"
    newH.dataset.field       = "text"
    newH.dataset.level       = level
    newH.dataset.placeholder = oldH.dataset.placeholder || "Título..."
    newH.dataset.action      = oldH.dataset.action || "keydown->blocks-editor#titleKeydown"
    newH.innerHTML           = oldH.innerHTML

    oldH.replaceWith(newH)
    newH.focus()

    // Move caret to end
    const range = document.createRange()
    range.selectNodeContents(newH)
    range.collapse(false)
    const sel = window.getSelection()
    sel.removeAllRanges()
    sel.addRange(range)

    // Update active button
    wrapper.querySelectorAll(".titulo-level-btn").forEach(b => {
      b.classList.toggle("active", parseInt(b.dataset.level) === level)
    })
  }

  titleKeydown(event) {
    if (event.key !== "Enter") return
    event.preventDefault()

    const blockEl  = event.target.closest(".block-item")
    const newBlock = this._createBlockElement("texto", this._uid(), {})
    blockEl.after(newBlock)
    this._updateEmptyState()
    this._focusFirstInput(newBlock)
  }

  // ── Floating toolbar ─────────────────────────────────────────────────

  _buildToolbar() {
    const t = document.createElement("div")
    t.id        = "blocks-floating-toolbar"
    t.className = "blocks-floating-toolbar"
    t.style.display = "none"

    // Group 1: text formatting
    const fmtCmds = [
      { cmd: "bold",          html: "<b>B</b>",  title: "Negrito" },
      { cmd: "italic",        html: "<i>I</i>",  title: "Itálico" },
      { cmd: "underline",     html: "<u>U</u>",  title: "Sublinhado" },
      { cmd: "strikeThrough", html: "<s>S</s>",  title: "Tachado" },
    ]
    fmtCmds.forEach(({ cmd, html, title }) => {
      const btn = this._mkBtn(html, title, "toolbar-btn fmt-btn")
      btn.dataset.cmd = cmd
      btn.addEventListener("mousedown", (e) => {
        e.preventDefault()
        document.execCommand(cmd, false, null)
        this._updateToolbarState()
      })
      t.appendChild(btn)
    })

    t.appendChild(this._mkSep())

    // Group 2: lists
    ;[
      { cmd: "insertOrderedList",   html: "OL", title: "Lista numerada" },
      { cmd: "insertUnorderedList", html: "UL", title: "Lista com marcadores" },
    ].forEach(({ cmd, html, title }) => {
      const btn = this._mkBtn(html, title, "toolbar-btn")
      btn.addEventListener("mousedown", (e) => {
        e.preventDefault()
        document.execCommand(cmd, false, null)
        this._updateToolbarState()
      })
      t.appendChild(btn)
    })

    t.appendChild(this._mkSep())

    // Group 3: link
    const linkPanel = document.createElement("div")
    linkPanel.className   = "toolbar-link-panel"
    linkPanel.style.display = "none"

    const linkInput = document.createElement("input")
    linkInput.type        = "url"
    linkInput.placeholder = "https://..."
    linkInput.className   = "toolbar-link-input"

    const applyLink = () => {
      const url = linkInput.value.trim()
      if (!url) return
      this._restoreSelection()
      document.execCommand("createLink", false, url)
      // Make links open in new tab
      const sel = window.getSelection()
      if (sel && sel.rangeCount) {
        const range = sel.getRangeAt(0)
        const container = range.commonAncestorContainer
        const anchors = (container.nodeType === Node.ELEMENT_NODE ? container : container.parentElement)
          ?.querySelectorAll("a")
        anchors?.forEach(a => { a.target = "_blank"; a.rel = "noopener noreferrer" })
      }
      linkPanel.style.display = "none"
    }

    linkInput.addEventListener("keydown", (e) => {
      if (e.key === "Enter")  { e.preventDefault(); applyLink() }
      if (e.key === "Escape") { linkPanel.style.display = "none" }
    })

    const applyBtn = this._mkBtn("↵", "Aplicar link", "toolbar-link-apply")
    applyBtn.addEventListener("mousedown", (e) => { e.preventDefault(); applyLink() })

    const unlinkBtn = this._mkBtn("×", "Remover link", "toolbar-link-remove")
    unlinkBtn.addEventListener("mousedown", (e) => {
      e.preventDefault()
      this._restoreSelection()
      document.execCommand("unlink", false, null)
      linkPanel.style.display = "none"
    })

    linkPanel.append(linkInput, applyBtn, unlinkBtn)

    const linkBtn = this._mkBtn("🔗", "Link", "toolbar-btn")
    linkBtn.addEventListener("mousedown", (e) => {
      e.preventDefault()
      this._savedRange = window.getSelection()?.getRangeAt(0)?.cloneRange()
      const visible = linkPanel.style.display !== "none"
      this._closeAllPanels()
      if (!visible) {
        linkPanel.style.display = "flex"
        setTimeout(() => linkInput.focus(), 0)
      }
    })
    t.appendChild(linkBtn)
    t.appendChild(linkPanel)

    t.appendChild(this._mkSep())

    // Group 4: font color
    const fgPanel = this._mkColorPanel((color) => {
      this._restoreSelection()
      if (color) document.execCommand("foreColor", false, color)
      else        document.execCommand("removeFormat", false, null)
      fgPanel.style.display = "none"
    })

    const fgBtn = this._mkBtn(
      `<span style="border-bottom:2px solid #ec4899;padding-bottom:1px;font-weight:700">A</span>`,
      "Cor do texto", "toolbar-btn"
    )
    fgBtn.addEventListener("mousedown", (e) => {
      e.preventDefault()
      this._savedRange = window.getSelection()?.getRangeAt(0)?.cloneRange()
      const visible = fgPanel.style.display !== "none"
      this._closeAllPanels()
      if (!visible) fgPanel.style.display = "flex"
    })
    t.appendChild(fgBtn)
    t.appendChild(fgPanel)

    t.appendChild(this._mkSep())

    // Group 5: background color
    const bgPanel = this._mkColorPanel((color) => {
      this._restoreSelection()
      document.execCommand("hiliteColor", false, color || "transparent")
      bgPanel.style.display = "none"
    }, true)

    const bgBtn = this._mkBtn(
      `<span style="background:#fde68a;padding:0 3px;border-radius:2px">H</span>`,
      "Cor de fundo", "toolbar-btn"
    )
    bgBtn.addEventListener("mousedown", (e) => {
      e.preventDefault()
      this._savedRange = window.getSelection()?.getRangeAt(0)?.cloneRange()
      const visible = bgPanel.style.display !== "none"
      this._closeAllPanels()
      if (!visible) bgPanel.style.display = "flex"
    })
    t.appendChild(bgBtn)
    t.appendChild(bgPanel)

    return t
  }

  _mkBtn(html, title, className) {
    const btn = document.createElement("button")
    btn.type      = "button"
    btn.className = className
    btn.title     = title
    btn.innerHTML = html
    return btn
  }

  _mkSep() {
    const sep = document.createElement("div")
    sep.className = "toolbar-sep"
    return sep
  }

  _mkColorPanel(onSelect, bg = false) {
    const panel = document.createElement("div")
    panel.className     = "toolbar-color-panel"
    panel.style.display = "none"

    TOOLBAR_COLORS.forEach(color => {
      const sw = document.createElement("button")
      sw.type      = "button"
      sw.className = "toolbar-swatch"
      sw.title     = color
      sw.style.background = bg ? color + "88" : color
      sw.addEventListener("mousedown", (e) => { e.preventDefault(); onSelect(bg ? color + "88" : color) })
      panel.appendChild(sw)
    })

    const clear = document.createElement("button")
    clear.type      = "button"
    clear.className = "toolbar-swatch toolbar-swatch-clear"
    clear.title     = "Limpar cor"
    clear.textContent = "×"
    clear.addEventListener("mousedown", (e) => { e.preventDefault(); onSelect(null) })
    panel.appendChild(clear)

    return panel
  }

  _closeAllPanels() {
    if (!this._toolbar) return
    this._toolbar.querySelectorAll(".toolbar-link-panel, .toolbar-color-panel").forEach(p => {
      p.style.display = "none"
    })
  }

  _restoreSelection() {
    if (!this._savedRange) return
    const sel = window.getSelection()
    sel.removeAllRanges()
    sel.addRange(this._savedRange)
  }

  _handleSelectionChange() {
    const sel = window.getSelection()
    if (!sel || sel.rangeCount === 0 || sel.isCollapsed) {
      // Don't hide if a sub-panel (link input, color panel) is open
      const anyOpen = [...this._toolbar.querySelectorAll(".toolbar-link-panel, .toolbar-color-panel")]
        .some(p => p.style.display !== "none")
      if (!anyOpen) this._hideToolbar()
      return
    }

    const range  = sel.getRangeAt(0)
    const anchor = range.commonAncestorContainer
    const textField = anchor.nodeType === Node.TEXT_NODE
      ? anchor.parentElement?.closest(".block-field-texto")
      : anchor.closest?.(".block-field-texto")

    if (!textField) {
      this._hideToolbar()
      return
    }

    this._savedRange = range.cloneRange()
    this._toolbar.style.display = "flex"
    this._positionToolbar(range)
    this._updateToolbarState()
  }

  _positionToolbar(range) {
    const rect   = range.getBoundingClientRect()
    const height = this._toolbar.getBoundingClientRect().height || 44
    const width  = this._toolbar.getBoundingClientRect().width  || 320

    let top = rect.top - height - 8
    if (top < 8) top = rect.bottom + 8

    let left = rect.left + rect.width / 2 - width / 2
    left = Math.max(8, Math.min(left, window.innerWidth - width - 8))

    this._toolbar.style.top  = `${top}px`
    this._toolbar.style.left = `${left}px`
  }

  _hideToolbar() {
    if (!this._toolbar) return
    this._toolbar.style.display = "none"
    this._closeAllPanels()
  }

  _updateToolbarState() {
    if (!this._toolbar) return
    this._toolbar.querySelectorAll(".fmt-btn[data-cmd]").forEach(btn => {
      try {
        btn.classList.toggle("active", document.queryCommandState(btn.dataset.cmd))
      } catch (_) {}
    })
  }

  _handleDocClick(event) {
    if (!this._toolbar) return

    // Toolbar: hide only when clicking outside both the toolbar and text fields
    if (!this._toolbar.contains(event.target) && !event.target.closest?.(".block-field-texto")) {
      this._hideToolbar()
    }

    // Image editor: always runs regardless of where the click landed
    // Only carousel navigation buttons must not activate editing mode
    const inCarouselNav = !!event.target.closest?.(".carrossel-btn, .carrossel-dot")
    const clickedEditor = inCarouselNav ? null : event.target.closest?.(".imagem-editor")
    if (clickedEditor !== this._activeImageEditor) {
      // Deactivate previous → switch to preview mode (if it has images)
      if (this._activeImageEditor) {
        const hasImages = this._activeImageEditor.querySelectorAll(".imagem-grid-item").length > 0
        if (hasImages) this._activeImageEditor.classList.add("imagem-editor--preview")
      }
      // Activate new → switch to editing mode
      if (clickedEditor) clickedEditor.classList.remove("imagem-editor--preview")
      this._activeImageEditor = clickedEditor || null
    }

    // Video editor two-state management
    const clickedVideoEditor = event.target.closest?.(".block-media-editor")
    if (clickedVideoEditor !== this._activeVideoEditor) {
      // Deactivate previous → inject iframe now that it will be visible
      if (this._activeVideoEditor) {
        const embed = this._activeVideoEditor.querySelector("[data-field='embedUrl']")?.value
        if (embed) {
          const slot = this._activeVideoEditor.querySelector(".block-media-preview-slot")
          if (slot) slot.innerHTML = this._videoIframeHtml(embed)
          this._activeVideoEditor.classList.add("block-media-editor--preview")
        }
      }
      // Activate new → remove iframe from DOM (stops playback) and exit preview
      if (clickedVideoEditor) {
        const slot = clickedVideoEditor.querySelector(".block-media-preview-slot")
        if (slot) slot.innerHTML = ""
        clickedVideoEditor.classList.remove("block-media-editor--preview")
      }
      this._activeVideoEditor = clickedVideoEditor || null
    }
  }

  _handleDocKeydown(event) {
    if (event.key === "Escape") this._hideToolbar()
  }

  _handlePaste(event) {
    const target = event.target.closest?.(".block-field-texto")
    if (!target) return

    const text = event.clipboardData?.getData("text/plain") || ""
    if (!text) return

    if (!this._isLikelyMarkdown(text)) return

    event.preventDefault()
    const html = this._markdownToHtml(text)
    document.execCommand("insertHTML", false, html)
  }

  _isLikelyMarkdown(text) {
    const patterns = [
      /^#{1,6}\s+/m,
      /^\s*[-*+]\s+/m,
      /^\s*\d+\.\s+/m,
      /^\s*>\s+/m,
      /```/, /`[^`]+`/,
      /\*\*[^*]+\*\*/, /__[^_]+__/,
      /\[[^\]]+\]\([^)]+\)/,
    ]
    return patterns.some((re) => re.test(text))
  }

  _markdownToHtml(md) {
    const lines = md.replace(/\r\n/g, "\n").split("\n")
    const out = []
    let inUl = false
    let inOl = false
    let inCode = false
    let codeLines = []
    let para = []

    const flushPara = () => {
      if (!para.length) return
      out.push(`<p>${this._mdInline(para.join("<br>"))}</p>`)
      para = []
    }

    const closeLists = () => {
      if (inUl) { out.push("</ul>"); inUl = false }
      if (inOl) { out.push("</ol>"); inOl = false }
    }

    lines.forEach((raw) => {
      const line = raw.replace(/\t/g, "  ")
      if (/^```/.test(line.trim())) {
        if (!inCode) {
          flushPara(); closeLists(); inCode = true; codeLines = []; return
        }
        inCode = false
        const code = this._escapeHtml(codeLines.join("\n"))
        out.push(`<pre><code>${code}</code></pre>`)
        codeLines = []
        return
      }

      if (inCode) { codeLines.push(raw); return }

      const heading = line.match(/^(#{1,6})\s+(.+)$/)
      if (heading) {
        flushPara(); closeLists()
        const level = heading[1].length
        out.push(`<h${level}>${this._mdInline(heading[2].trim())}</h${level}>`)
        return
      }

      const quote = line.match(/^\s*>\s+(.+)$/)
      if (quote) {
        flushPara(); closeLists()
        out.push(`<blockquote>${this._mdInline(quote[1].trim())}</blockquote>`)
        return
      }

      const ul = line.match(/^\s*[-*+]\s+(.+)$/)
      if (ul) {
        flushPara()
        if (!inUl) { closeLists(); out.push("<ul>"); inUl = true }
        out.push(`<li>${this._mdInline(ul[1].trim())}</li>`)
        return
      }

      const ol = line.match(/^\s*\d+\.\s+(.+)$/)
      if (ol) {
        flushPara()
        if (!inOl) { closeLists(); out.push("<ol>"); inOl = true }
        out.push(`<li>${this._mdInline(ol[1].trim())}</li>`)
        return
      }

      if (line.trim() === "") {
        flushPara(); closeLists(); return
      }

      para.push(this._escapeHtml(line))
    })

    flushPara(); closeLists()
    return out.join("")
  }

  _mdInline(text) {
    let s = this._escapeHtml(text)
    s = s.replace(/`([^`]+)`/g, "<code>$1</code>")
    s = s.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    s = s.replace(/__([^_]+)__/g, "<strong>$1</strong>")
    s = s.replace(/\*([^*]+)\*/g, "<em>$1</em>")
    s = s.replace(/_([^_]+)_/g, "<em>$1</em>")
    s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, "<a href=\"$2\" target=\"_blank\" rel=\"noopener noreferrer\">$1</a>")
    return s
  }

  _escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
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
      case "titulo": {
        const heading = el.querySelector("[data-field='text']")
        return {
          text:  heading?.textContent?.trim() ?? "",
          level: parseInt(heading?.dataset.level) || 2,
        }
      }

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

      case "imagem": {
        const editor = el.querySelector(".imagem-editor")
        const layout = editor?.dataset.layout || "galeria"
        const images = [...el.querySelectorAll(".imagem-grid-item")]
          .map(item => ({ url: item.dataset.url || "", alt: "" }))
          .filter(img => img.url)
        return { layout, images }
      }
      case "video":    return { url: val("[data-field='url']"), embedUrl: val("[data-field='embedUrl']") }
      case "divisor":  return {}
      case "destaque": {
        const editor = el.querySelector(".destaque-editor")
        return {
          text:  html("[data-field='text']"),
          color: editor?.dataset.color || "#fef9c3",
        }
      }
      default:         return {}
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
      if (!b.type || !BLOCK_TYPES[b.type]) return
      const blockEl = this._createBlockElement(b.type, b.id || this._uid(), b.data || {})
      this.canvasTarget.appendChild(blockEl)
      // Init image grid after mounting
      if (b.type === "imagem") {
        this._initImageGridSortable(blockEl)
        this._refreshImagePreview(blockEl)
        // Start in preview mode if block already has images
        const editor = blockEl.querySelector(".imagem-editor")
        const hasImages = blockEl.querySelectorAll(".imagem-grid-item").length > 0
        if (editor && hasImages) editor.classList.add("imagem-editor--preview")
      }
      // Video: inject iframe and start in preview mode if it already has an embed URL
      if (b.type === "video") {
        const editor = blockEl.querySelector(".block-media-editor")
        const embed  = blockEl.querySelector("[data-field='embedUrl']")?.value
        if (editor && embed) {
          const slot = editor.querySelector(".block-media-preview-slot")
          if (slot) slot.innerHTML = this._videoIframeHtml(embed)
          editor.classList.add("block-media-editor--preview")
        }
      }
    })

    this._updateEmptyState()
    this.canvasTarget.querySelectorAll("textarea").forEach(t => this.autoResize(t))
  }

  // ── Helpers ──────────────────────────────────────────────────────────

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
    const input = blockEl.querySelector("[contenteditable='true'], input[type='text'], textarea")
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

  _videoIframeHtml(embedUrl) {
    const e = (s) => String(s ?? "").replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    return `<iframe class="block-media-preview block-media-preview--video"
                    src="${e(embedUrl)}"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    allowfullscreen></iframe>`
  }

  _parseVideoUrl(url) {
    if (!url) return null
    const yt = url.match(/(?:youtube(?:-nocookie)?\.com\/(?:watch\?(?:.*&)?v=|embed\/|shorts\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
    const vimeo = url.match(/(?:vimeo\.com\/(?:video\/)?)(\d+)/)
    if (yt) return `https://www.youtube-nocookie.com/embed/${yt[1]}`
    if (vimeo) return `https://player.vimeo.com/video/${vimeo[1]}`
    return null
  }
}
