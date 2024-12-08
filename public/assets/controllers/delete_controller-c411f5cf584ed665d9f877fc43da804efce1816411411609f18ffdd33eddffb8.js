import { Controller } from "@hotwired/stimulus"

const getCsrfToken = () => {
  const metaTag = document.querySelector('meta[name="csrf-token"]');
  return metaTag ? metaTag.getAttribute('content') : '';
}

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // Inicializa el modal de Bootstrap
    this.modal = new bootstrap.Modal(document.getElementById('deleteConfirmationModal'))
  }

  confirm(event) {
    event.preventDefault()

    // Obtén la URL del formulario de eliminación
    const url = this.data.get("url")

    // Envía la solicitud DELETE utilizando Turbo
    Turbo.navigator.submitForm(new FormData(), url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      turbo_frame: "families"
    })

    // Oculta el modal
    this.modal.hide()
  }

  show(event) {
    event.preventDefault()

    // Obtén la URL del botón de eliminación y almacénala en el controlador
    const url = event.currentTarget.getAttribute("data-url")
    this.data.set("url", url)

    // Muestra el modal
    this.modal.show()
  }

  cancel(event) {
    
    this.modal.hide()
  }
};
