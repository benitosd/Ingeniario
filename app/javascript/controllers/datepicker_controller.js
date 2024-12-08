import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    flatpickr(this.element, {dateFormat: "d/m/Y",
    altInput: true,  // Habilitar entrada alternativa
    altFormat: "d/m/Y",  // Formato que se mostrará al usuario
    allowInput: true
    })
  }
}