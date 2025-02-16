import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.content.cloneNode(true)
    
    // Reemplazar los índices placeholder con timestamp
    const timestamp = new Date().getTime()
    const html = content.children[0].outerHTML.replace(/NEW_RECORD/g, timestamp)
    
    this.containerTarget.insertAdjacentHTML('beforeend', html)
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest(".nested-fields")
    item.remove()
  }
}