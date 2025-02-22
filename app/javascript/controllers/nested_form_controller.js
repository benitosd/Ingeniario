import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["add_item", "template", "container"]

  add(event) {
    event.preventDefault()
    let content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    let item = event.target.closest(".nested-fields")
    item.remove()
  }

  removeField(event) {
    event.preventDefault()
    const item = event.target.closest(".nested-fields")
    const destroyField = item.querySelector('input[name*="_destroy"]')
    if (destroyField) {
      destroyField.value = 1
      item.style.display = 'none'
    } else {
      item.remove()
    }
  }
}