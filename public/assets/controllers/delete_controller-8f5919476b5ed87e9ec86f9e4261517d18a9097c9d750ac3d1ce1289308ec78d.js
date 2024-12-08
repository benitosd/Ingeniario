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
  console.log("Confirm button clicked")
  this.urlValue = event.target.closest('tr').dataset.editableId
  console.log(`URL Value: ${this.urlValue}`)
  this.modal.show()
  }

  async delete() {
    try {
      const response = await fetch(`/families/${this.urlValue}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      if (response.ok) {
        document.getElementById(`family_${this.urlValue}`).remove()
        this.modal.hide()
      } else {
        console.error('Failed to delete the item.', response)
        alert('Failed to delete the item.')
      }
    } catch (error) {
      console.error('Error occurred while deleting the item.', error)
      alert('Error occurred while deleting the item.')
    }
  }
}
;
