// app/javascript/controllers/editable_controller.js
import { Controller } from "@hotwired/stimulus"

const getCsrfToken = () => {
  const metaTag = document.querySelector('meta[name="csrf-token"]');
  return metaTag ? metaTag.getAttribute('content') : '';
}

export default class extends Controller {
  static targets = ["nameText", "descriptionText", "nameInput", "descriptionInput"]

  edit() {
    this.toggleEditMode(true)
  }

  save() {
    const id = this.element.dataset.editableId
    const data = {
      name: this.nameInputTarget.value,
      description: this.descriptionInputTarget.value
    }

    fetch(`/families/${id}/update_inline`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": getCsrfToken()
      },
      body: JSON.stringify({ family: data })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.nameTextTarget.textContent = data.family.name
        this.descriptionTextTarget.textContent = data.family.description
        this.toggleEditMode(false)
      } else {
        alert('Error: ' + data.errors.join(', '))
      }
    })
    .catch(error => console.error('Error:', error))
  }

  cancel() {
    this.toggleEditMode(false)
  }
  cancel() {
    this.toggleEditMode(false)
  }

  toggleEditMode(editMode) {
    this.nameTextTarget.classList.toggle('d-none', editMode)
    this.descriptionTextTarget.classList.toggle('d-none', editMode)
    this.nameInputTarget.classList.toggle('d-none', !editMode)
    this.descriptionInputTarget.classList.toggle('d-none', !editMode)
    this.element.querySelector('.edit-button').classList.toggle('d-none', editMode)
    this.element.querySelector('.save-button').classList.toggle('d-none', !editMode)
    this.element.querySelector('.cancel-button').classList.toggle('d-none', !editMode)
  }
};
