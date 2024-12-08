import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.modalTarget.style.display = 'block'
  }

  close() {
    this.modalTarget.style.display = 'none'
  }

  async submitForm(event) {
    event.preventDefault()

    const form = event.target
    const formData = new FormData(form)
    
    try {
      const response = await fetch(form.action, {
        method: form.method,
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Accept': 'application/json'
        }
      })

      if (response.ok) {
        const result = await response.json()
        if (result.status === 'success') {
          // Add new family to the list
          document.getElementById('families-list').innerHTML += `
            <tr>
              <td>${result.family.name}</td>
              <td>${result.family.description}</td>
            </tr>
          `
          this.close()
        } else {
          // Handle validation errors
          alert(result.message)
        }
      } else {
        alert('Failed to create the family.')
      }
    } catch (error) {
      console.error('Error:', error)
      alert('An error occurred.')
    }
  }
};
