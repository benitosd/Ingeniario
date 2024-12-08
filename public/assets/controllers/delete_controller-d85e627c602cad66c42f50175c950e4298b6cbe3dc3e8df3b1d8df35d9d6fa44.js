// app/javascript/controllers/delete_controller.js
import { Controller } from "@hotwired/stimulus"

const getCsrfToken = () => {
  const metaTag = document.querySelector('meta[name="csrf-token"]');
  return metaTag ? metaTag.getAttribute('content') : '';
}


export default class extends Controller {
  static values = { url: String }

  connect() {
    this.modal = new bootstrap.Modal(document.getElementById('deleteConfirmationModal'))
    this.confirmButton = document.getElementById('confirmDeleteButton')
    this.confirmButton.addEventListener('click', this.delete.bind(this))
  }

  confirm(event) {
    event.preventDefault()
    this.urlValue = event.target.closest('tr').dataset.editableId
    this.modal.show()
  }

  delete() {
    fetch(`/families/${this.urlValue}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    .then(response => {
      if (response.ok) {
        document.getElementById(`family_${this.urlValue}`).remove()
        this.modal.hide()
      } else {
        alert('Failed to delete the item.')
      }
    })
  }
};
