import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "selectContainer", "inputContainer", "input"]
  
  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  }
  
  onSelectChange(event) {
    if (event.target.value === "__create_new__") {
      event.preventDefault()
      this.showCreateForm()
      // Reset select to previous value
      this.selectTarget.value = ""
    }
  }
  
  showCreateForm() {
    // Mostrar campo de input e ocultar select
    this.selectContainerTarget.classList.add("hidden")
    this.inputContainerTarget.classList.remove("hidden")
    this.inputTarget.focus()
  }
  
  cancelCreate() {
    // Voltar para o select
    this.inputContainerTarget.classList.add("hidden")
    this.selectContainerTarget.classList.remove("hidden")
    this.inputTarget.value = ""
  }
  
  async createCategoria(event) {
    // Prevenir submit do formulário quando pressionar Enter
    if (event) {
      event.preventDefault()
    }
    
    const nome = this.inputTarget.value.trim()
    
    if (!nome) {
      alert("Por favor, digite o nome da categoria")
      this.inputTarget.focus()
      return
    }
    
    try {
      // Construir URL relativa ao contexto atual (funciona dentro de engines)
      const baseUrl = window.location.pathname.split('/admin/')[0]
      const createUrl = `${baseUrl}/admin/categorias`
      
      const response = await fetch(createUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          categoria: { nome: nome }
        })
      })
      
      const data = await response.json()
      
      if (response.ok) {
        // Adicionar a nova categoria ao select
        const newOption = new Option(data.nome, data.id, true, true)
        
        // Adicionar ao final do select
        this.selectTarget.add(newOption)
        
        // Atualizar também o array global para o taxonomy-suggestions
        if (window.universidadeCategorias) {
          window.universidadeCategorias.push({ id: data.id, nome: data.nome })
        }
        
        // Voltar para o select com a nova categoria selecionada
        this.inputContainerTarget.classList.add("hidden")
        this.selectContainerTarget.classList.remove("hidden")
        this.inputTarget.value = ""
        
        // Disparar evento change no select para notificar outros controllers
        this.selectTarget.dispatchEvent(new Event('change'))
      } else {
        alert(data.error || "Erro ao criar categoria")
      }
    } catch (error) {
      console.error("Erro ao criar categoria:", error)
      alert("Erro ao criar categoria. Tente novamente.")
    }
  }
}
