import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    // Lee el estado guardado y actualiza el ícono del botón
    const cardsHidden = localStorage.getItem("cardsHidden")
    if (cardsHidden === "true") {
      this.buttonTarget.innerHTML = '<i class="fas fa-eye"></i>'  // Indica "mostrar"
    } else {
      this.buttonTarget.innerHTML = '<i class="fas fa-eye-slash"></i>'  // Indica "ocultar"
    }
  }

  toggle() {
    console.log("toggle top button clicked")
    // Alterna el estado y actualiza el ícono
    let cardsHidden = localStorage.getItem("cardsHidden")
    if (cardsHidden === "true") {
      localStorage.setItem("cardsHidden", "false")
      this.buttonTarget.innerHTML = '<i class="fas fa-eye-slash"></i>'
    } else {
      localStorage.setItem("cardsHidden", "true")
      this.buttonTarget.innerHTML = '<i class="fas fa-eye"></i>'
    }
    // Dispara un evento global para notificar a otros controladores
    document.dispatchEvent(new CustomEvent("toggleCards"))
  }
}
