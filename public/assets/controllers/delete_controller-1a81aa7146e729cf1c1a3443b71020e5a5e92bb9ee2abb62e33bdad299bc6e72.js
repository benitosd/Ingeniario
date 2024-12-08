import { Controller } from "@hotwired/stimulus"

const getCsrfToken = () => {
  const metaTag = document.querySelector('meta[name="csrf-token"]');
  return metaTag ? metaTag.getAttribute('content') : '';
}

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.modal = new bootstrap.Modal(document.getElementById('deleteConfirmationModal'))
  }

  confirm(event) {
    event.preventDefault()
    const url = event.currentTarget.getAttribute("href")
    
    Turbo.navigator.submitForm(new FormData(), url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      turbo_frame: "families"
    })

    this.modal.hide()
  }

  show(event) {
    event.preventDefault()
    this.modal.show()
  }

  cancel(event) {
    event.preventDefault()
    this.modal.hide()
  }
};
