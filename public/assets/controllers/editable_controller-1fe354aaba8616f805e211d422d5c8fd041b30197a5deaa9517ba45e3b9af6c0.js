// app/javascript/controllers/editable_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal"]
    
    initialize() {
      this.modal = document.getElementById('deleteModal')
      this.currentId = null
      this.currentUrl = null
    }
    
    confirm(event) {
      this.currentId = event.currentTarget.dataset.id
      this.currentUrl = event.currentTarget.dataset.url
      this.modal.style.display = 'block'
    }
  
    confirmDelete() {
      if (this.currentUrl) {
        fetch(this.currentUrl, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          }
        })
        .then(response => {
          if (response.ok) {
            window.location.reload()
          } else {
            alert('Failed to delete the item.')
          }
        })
      }
    }
};
