import { Controller } from "@hotwired/stimulus"

// Stimulus controller for the custom rich-text editor built on top of contenteditable.
// Provides formatting commands, media insertion, serialization, and a small color picker
// for highlighted boxes.
export default class extends Controller {
  static targets = ["content", "hidden", "toolbar"]
  static values  = { uploadUrl: String, initialContent: String }

  connect() {
    this._handleKeydown = this._onKeydown.bind(this)
    this._handlePaste   = this._onPaste.bind(this)
    this._handleClick   = this._handleToolbarClick.bind(this)

    this._colorMenu     = null
    this._createFileInput()
    this._loadInitialContent()

    this.contentTarget.addEventListener("keydown", this._handleKeydown)
    this.contentTarget.addEventListener("paste", this._handlePaste)
    this.toolbarTarget.addEventListener("click", this._handleClick)

    const form = this.element.closest("form")
    if (form) form.addEventListener("submit", this.serialize.bind(this))
  }

  disconnect() {
    this.contentTarget.removeEventListener("keydown", this._handleKeydown)
    this.contentTarget.removeEventListener("paste", this._handlePaste)
    this.toolbarTarget.removeEventListener("click", this._handleClick)
    if (this._colorMenu) this._colorMenu.remove()
  }

  // Serialize editor HTML into the hidden field prior to submit.
  serialize(event) {
    if (event) event.preventDefault()
    this.hiddenTarget.value = this.contentTarget.innerHTML.trim()
    if (event) {
      event.target.submit()
    }
  }

  // Handle all toolbar button clicks via event delegation.
  _handleToolbarClick(event) {
    const button = event.target.closest("[data-command]")
    if (!button) return
    event.preventDefault()
    const command = button.dataset.command

    switch (command) {
      case "block":
        this.applyBlock(button.dataset.value)
        break
      case "bold":
        this.applyInline("bold")
        break
      case "italic":
        this.applyInline("italic")
        break
      case "link":
        this.toggleLink()
        break
      case "ul":
        this.applyInline("insertUnorderedList")
        break
      case "ol":
        this.applyInline("insertOrderedList")
        break
      case "colorBox":
        this.showColorPicker(button)
        break
      case "image":
        this.addImage()
        break
      case "video":
        this.addVideo()
        break
      default:
        break
    }
  }

  applyBlock(tagName) {
    this._focusContent()
    document.execCommand("formatBlock", false, tagName)
  }

  applyInline(command) {
    this._focusContent()
    document.execCommand(command, false)
  }

  toggleLink() {
    this._focusContent()
    const selection = window.getSelection()
    if (!selection || selection.rangeCount === 0) return

    const existingLink = this._currentLink(selection)
    if (existingLink) {
      const currentHref = existingLink.getAttribute("href") || ""
      const input = window.prompt("Editar link (deixe vazio para remover):", currentHref)
      if (input === null) return
      if (input.trim() === "") {
        document.execCommand("unlink", false)
        return
      }
      existingLink.setAttribute("href", input.trim())
      existingLink.setAttribute("target", "_blank")
      existingLink.setAttribute("rel", "noopener noreferrer")
      return
    }

    if (selection.isCollapsed) {
      const url = window.prompt("Cole a URL do link:")
      if (!url || url.trim() === "") return
      const text = url.trim()
      document.execCommand("insertHTML", false, `<a href="${text}" target="_blank" rel="noopener noreferrer">${text}</a>`)
      return
    }

    const url = window.prompt("Cole a URL do link:")
    if (!url || url.trim() === "") return
    document.execCommand("createLink", false, url.trim())
    this._decorateLinks()
  }

  showColorPicker(button) {
    if (this._colorMenu) this._colorMenu.remove()

    const menu = document.createElement("div")
    menu.className = "editor-color-menu"
    const colors = {
      "Amarelo": "#FFF9C4",
      "Azul": "#E3F2FD",
      "Verde": "#E8F5E9",
      "Vermelho": "#FFEBEE"
    }

    Object.entries(colors).forEach(([label, value]) => {
      const option = document.createElement("button")
      option.type = "button"
      option.dataset.color = value
      option.textContent = label
      option.style.backgroundColor = value
      option.addEventListener("click", () => {
        this.applyColorBox(value)
        menu.remove()
        this._colorMenu = null
      })
      menu.appendChild(option)
    })

    const rect = button.getBoundingClientRect()
    menu.style.top = `${rect.bottom + window.scrollY + 6}px`
    menu.style.left = `${rect.left + window.scrollX}px`
    document.body.appendChild(menu)
    this._colorMenu = menu
  }

  applyColorBox(color) {
    this._focusContent()
    const selection = window.getSelection()
    if (!selection || selection.rangeCount === 0) return

    const range = selection.getRangeAt(0)
    const wrapper = document.createElement("div")
    wrapper.className = "caixa-colorida"
    wrapper.style.backgroundColor = color

    if (range.collapsed) {
      const block = this._closestBlock(range.startContainer) || this._appendParagraph()
      if (block.tagName === "LI") {
        const list = block.closest("ul,ol")
        const paragraph = document.createElement("p")
        paragraph.innerHTML = block.innerHTML || "<br>"
        wrapper.appendChild(paragraph)
        list.insertAdjacentElement("afterend", wrapper)
        block.remove()
        if (list.children.length === 0) list.remove()
      } else {
        wrapper.appendChild(block.cloneNode(true))
        block.replaceWith(wrapper)
      }
    } else {
      const content = range.extractContents()
      wrapper.appendChild(content)
      range.insertNode(wrapper)
    }

    this._placeCursor(wrapper)
  }

  addImage() {
    const url = window.prompt("Cole a URL da imagem ou deixe vazio para enviar um arquivo")
    if (url && url.trim() !== "") {
      this.insertBlock(`<img src="${url.trim()}" alt="Imagem" />`)
      return
    }

    if (!this.hasUploadUrlValue) {
      window.alert("Envio de imagem não configurado.")
      return
    }

    this._fileInput.value = ""
    this._fileInput.click()
  }

  addVideo() {
    const raw = window.prompt("Cole o link do YouTube ou Vimeo")
    if (!raw || raw.trim() === "") return
    const url = raw.trim()
    const yt = url.match(/(?:youtube(?:-nocookie)?\.com\/(?:watch\?(?:.*&)?v=|embed\/|shorts\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
    const vimeo = url.match(/(?:vimeo\.com\/(?:video\/)?)(\d+)/)

    let embedUrl = null
    if (yt) embedUrl = `https://www.youtube-nocookie.com/embed/${yt[1]}`
    if (vimeo) embedUrl = `https://player.vimeo.com/video/${vimeo[1]}`

    if (!embedUrl) {
      window.alert("URL não reconhecida. Use um link do YouTube ou Vimeo.")
      return
    }

    const html = `<iframe src="${embedUrl}" allowfullscreen></iframe>`
    this.insertBlock(html)
  }

  insertBlock(html) {
    this._focusContent()
    const selection = window.getSelection()
    const range = selection && selection.rangeCount > 0 ? selection.getRangeAt(0) : this._rangeAtEnd()
    if (!range) return

    const block = document.createElement("div")
    block.innerHTML = html
    block.className = "editor-block"

    range.deleteContents()
    range.insertNode(block)
    this._placeCursor(block)
  }

  _onPaste(event) {
    event.preventDefault()
    const text = event.clipboardData.getData("text/plain")
    document.execCommand("insertText", false, text)
  }

  _onKeydown(event) {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "b") {
      event.preventDefault(); this.applyInline("bold"); return
    }
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "i") {
      event.preventDefault(); this.applyInline("italic"); return
    }

    if (event.key !== "Enter") return
    const selection = window.getSelection()
    if (!selection || selection.rangeCount === 0) return
    const current = this._closestBlock(selection.anchorNode)
    if (!current) return

    if (this._isHeading(current)) {
      event.preventDefault()
      const paragraph = document.createElement("p")
      paragraph.innerHTML = "<br>"
      current.insertAdjacentElement("afterend", paragraph)
      this._placeCursor(paragraph)
      return
    }

    if (current.tagName === "LI" && current.textContent.trim() === "") {
      event.preventDefault()
      const list = current.closest("ul,ol")
      const paragraph = document.createElement("p")
      paragraph.innerHTML = "<br>"
      if (list) {
        list.insertAdjacentElement("afterend", paragraph)
        current.remove()
        if (list.children.length === 0) list.remove()
      } else {
        current.insertAdjacentElement("afterend", paragraph)
        current.remove()
      }
      this._placeCursor(paragraph)
    }
  }

  _loadInitialContent() {
    const initial = this.initialContentValue || this.hiddenTarget.value || ""
    this.contentTarget.innerHTML = initial.trim() !== "" ? initial : "<p><br></p>"
  }

  _createFileInput() {
    this._fileInput = document.createElement("input")
    this._fileInput.type = "file"
    this._fileInput.accept = "image/*"
    this._fileInput.style.display = "none"
    this._fileInput.addEventListener("change", async (event) => {
      const file = event.target.files[0]
      if (!file) return
      await this._uploadImage(file)
    })
    this.element.appendChild(this._fileInput)
  }

  async _uploadImage(file) {
    if (!this.hasUploadUrlValue) return
    const formData = new FormData()
    formData.append("image", file)

    try {
      const response = await fetch(this.uploadUrlValue, {
        method: "POST",
        headers: { "X-CSRF-Token": this._csrfToken() },
        body: formData
      })

      if (!response.ok) {
        window.alert("Falha ao enviar a imagem.")
        return
      }

      const data = await response.json()
      const url = data.url || data.file?.url
      if (!url) {
        window.alert("Resposta inválida do servidor.")
        return
      }

      this.insertBlock(`<img src="${url}" alt="Imagem" />`)
    } catch (error) {
      console.error("Upload error", error)
      window.alert("Erro ao enviar a imagem.")
    }
  }

  _csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  _closestBlock(node) {
    if (!(node instanceof Node)) return null
    return node.nodeType === Node.ELEMENT_NODE && this._isBlock(node)
      ? node
      : (node.parentElement ? node.parentElement.closest("h1,h2,h3,p,div,li,ul,ol,blockquote") : null)
  }

  _isBlock(el) {
    return ["H1","H2","H3","P","DIV","LI","UL","OL","BLOCKQUOTE"].includes(el.tagName)
  }

  _isHeading(el) {
    return ["H1","H2","H3"].includes(el.tagName)
  }

  _appendParagraph() {
    const p = document.createElement("p")
    p.innerHTML = "<br>"
    this.contentTarget.appendChild(p)
    return p
  }

  _placeCursor(node) {
    const selection = window.getSelection()
    const range = document.createRange()
    range.selectNodeContents(node)
    range.collapse(false)
    selection.removeAllRanges()
    selection.addRange(range)
    this._focusContent()
  }

  _rangeAtEnd() {
    const range = document.createRange()
    range.selectNodeContents(this.contentTarget)
    range.collapse(false)
    return range
  }

  _currentLink(selection) {
    const node = selection.anchorNode
    if (!node) return null
    return node.parentElement ? node.parentElement.closest("a") : null
  }

  _decorateLinks() {
    this.contentTarget.querySelectorAll("a").forEach((a) => {
      a.setAttribute("target", "_blank")
      a.setAttribute("rel", "noopener noreferrer")
    })
  }

  _focusContent() {
    if (document.activeElement !== this.contentTarget) {
      this.contentTarget.focus()
    }
  }
}
