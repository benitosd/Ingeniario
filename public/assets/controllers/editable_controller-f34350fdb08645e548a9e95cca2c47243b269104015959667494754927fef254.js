// app/javascript/controllers/editable_controller.js
import { Controller } from "@hotwired/stimulus"


const getCsrfToken = () => {
    const metaTag = document.querySelector('meta[name="csrf-token"]');
    return metaTag ? metaTag.getAttribute('content') : '';
  }

  export default class extends Controller {
    static targets = ["text"]
  
    edit(event) {
      // El ID y el campo deben estar en el dataset del elemento
      const id = this.element.dataset.id
      const field = this.element.dataset.field
  
      // Mostrar el campo de entrada y ocultar el texto
      const inputField = this.element.querySelector('input[type="text"]')
      const textField = this.element.querySelector('.editable-text')
  
      inputField.classList.remove('d-none')
      inputField.focus()
      textField.classList.add('d-none')
    }
  
    update(event) {
      const id = this.element.dataset.id
      const field = this.element.dataset.field
      const value = event.target.value
  
      fetch(`/families/${id}/update_inline`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCsrfToken()
        },
        body: JSON.stringify({
          family: {
            [field]: value
          }
        })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Actualiza el texto y oculta el campo de entrada
          this.element.querySelector('.editable-text').textContent = data.updated_value
          this.element.querySelector('input[type="text"]').classList.add('d-none')
          this.element.querySelector('.editable-text').classList.remove('d-none')
        } else {
          alert('Error: ' + data.errors.join(', '))
        }
      })
      .catch(error => console.error('Error:', error))
    }
  };
