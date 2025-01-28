// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.modal = new Modal(this.element)
    
    // Prevenir que el modal se cierre al hacer clic fuera
    this.element.addEventListener('click', (e) => {
      if (e.target === this.element) {
        e.preventDefault()
      }
    })

    // Prevenir que el modal se cierre con la tecla Escape
    this.element.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        e.preventDefault()
      }
    })
  }

  open() {
    this.modal.show()
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    this.modal.hide()
  }

  submitForm(event) {
    event.preventDefault()
    const form = event.target
    
    // Enviar el formulario usando fetch
    fetch(form.action, {
      method: form.method,
      body: new FormData(form),
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    }).then(response => {
      if (response.ok) {
        this.close()
        window.location.reload()
      }
    })
  }
};
