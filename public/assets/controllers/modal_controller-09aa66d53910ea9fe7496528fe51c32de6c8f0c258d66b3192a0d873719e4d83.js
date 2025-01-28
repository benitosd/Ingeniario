// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.modal = new Modal(this.element)
  }

  hideBeforeSubmit(event) {
    // Prevenir que el modal se cierre automáticamente
    event.preventDefault()
    
    // Obtener el formulario
    const form = event.target
    
    // Enviar el formulario
    form.submit()
  }

  close() {
    this.modal.hide()
  }
};
