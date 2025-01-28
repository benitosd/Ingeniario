// app/javascript/controllers/warehouse_sections_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["warehouseSelect", "sectionSelect"]  // Añadimos warehouseSelect

  updateSections() {
    const warehouseId = this.warehouseSelectTarget.value
    
    if (!warehouseId) {
      this.sectionSelectTarget.innerHTML = '<option value="">Seleccione una sección</option>'
      return
    }

    fetch(`/warehouses/${warehouseId}/sections.json`)
      .then(response => response.json())
      .then(sections => {
        this.sectionSelectTarget.innerHTML = '<option value="">Seleccione una sección</option>' +
          sections.map(section => 
            `<option value="${section.id}">${section.name} - ${section.location_code || ''}</option>`
          ).join('')
      })
      .catch(error => {
        console.error('Error cargando secciones:', error)
        this.sectionSelectTarget.innerHTML = '<option value="">Error cargando secciones</option>'
      })
  }
}