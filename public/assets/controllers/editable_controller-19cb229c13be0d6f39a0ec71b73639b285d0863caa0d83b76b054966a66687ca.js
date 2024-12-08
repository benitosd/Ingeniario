// app/javascript/controllers/editable_controller.js
import { Controller } from "@hotwired/stimulus"
import { csrfToken } from "@rails/rails-ujs"

export default class extends Controller {
  static targets = ["field"]

  edit(event) {
    const id = event.currentTarget.dataset.id
    const field = event.currentTarget.dataset.field
    const frameId = `family_${id}_${field}`
    document.querySelector(`#${frameId}`).innerHTML = `
      <input type="text" name="${field}" value="${document.querySelector(`#${frameId}`).textContent}" data-action="blur->editable#update">
    `
  }

  update(event) {
    const id = this.element.dataset.id
    const field = this.element.dataset.field
    const value = event.target.value

    fetch(`/families/${id}/update_inline`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken()
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
        const frameId = `family_${id}_${field}`
        document.querySelector(`#${frameId}`).innerHTML = data.updated_value
      } else {
        alert('Error: ' + data.errors.join(', '))
      }
    })
  }
};
