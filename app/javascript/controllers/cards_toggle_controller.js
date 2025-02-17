import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    // Al conectarse, aplica el estado guardado
    const cardsHidden = localStorage.getItem("cardsHidden")
    if (cardsHidden === "true") {
      this.contentTarget.classList.add("hidden")
    } else {
      this.contentTarget.classList.remove("hidden")
    }
    // Escucha el evento global disparado desde el otro controlador
    document.addEventListener("toggleCards", this.toggle.bind(this))
  }

  toggle() {
    console.log("cards toggle event received")
    // Alterna la visibilidad agregando o removiendo la clase "hidden"
    if (this.contentTarget.classList.contains("hidden")) {
      this.contentTarget.classList.remove("hidden")
    } else {
      this.contentTarget.classList.add("hidden")
    }
  }
}
