import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trilhaSelect", "moduloSelect", "moduloOption"]

  connect() {
    this.filterModulos()
    this.syncHiddenFields()
  }

  filterModulos() {
    const trilhaId = this.trilhaSelectTarget.value
    
    // Resetar módulo se a trilha mudou
    this.moduloSelectTarget.value = ""
    
    this.moduloOptionTargets.forEach(option => {
      if (option.value === "") {
        // Sempre mostrar a opção vazia
        option.style.display = ""
      } else if (trilhaId === "") {
        // Se não há trilha selecionada, mostrar todos
        option.style.display = ""
      } else {
        // Mostrar apenas módulos da trilha selecionada
        const optionTrilhaId = option.dataset.trilhaId
        option.style.display = optionTrilhaId === trilhaId ? "" : "none"
      }
    })
    
    this.syncHiddenFields()
  }

  syncHiddenFields() {
    // Sincronizar valores com campos hidden no formulário principal
    const hiddenTrilha = document.getElementById("hidden_trilha_id")
    const hiddenModulo = document.getElementById("hidden_modulo_id")
    
    if (hiddenTrilha) {
      hiddenTrilha.value = this.trilhaSelectTarget.value
    }
    
    if (hiddenModulo) {
      hiddenModulo.value = this.moduloSelectTarget.value
    }
  }

  syncTitulo(event) {
    const hiddenTitulo = document.getElementById("hidden_titulo")
    if (hiddenTitulo) {
      hiddenTitulo.value = event.target.value
    }
  }

  syncTempo(event) {
    const hiddenTempo = document.getElementById("hidden_tempo_estimado")
    if (hiddenTempo) {
      hiddenTempo.value = event.target.value
    }
  }

  syncVisivel(event) {
    const hiddenVisivel = document.getElementById("hidden_visivel")
    if (hiddenVisivel) {
      hiddenVisivel.value = event.target.checked ? "1" : "0"
    }
  }
}
