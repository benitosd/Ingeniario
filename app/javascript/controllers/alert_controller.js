import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.classList.add('show')
    
    setTimeout(() => {
      this.close()
    }, 3000)
  }

  close() {
    this.element.classList.remove('show')
    setTimeout(() => {
      this.element.remove()
    }, 150)
  }
} 