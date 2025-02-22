import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "corejs-typeahead"

export default class extends Controller {
  static targets = ["input"]
  static values = { 
    selectedReference: String 
  }
  
  connect() {
    $(this.inputTarget).typeahead(
      {
        hint: true,
        highlight: true,
        minLength: 1
      },
      {
        name: 'stocks',
        source: this.queryStocks.bind(this),
        displayKey: 'reference',
        templates: {
          suggestion: function(stock) {
            return `<div>${stock.reference} - ${stock.item?.name || 'Sin nombre'}</div>`;
          }
        }
      }
    ).on('typeahead:select', (event, suggestion) => {
      // Guardamos la referencia seleccionada y actualizamos el valor
      this.selectedReferenceValue = suggestion.reference;
      this.inputTarget.value = suggestion.reference;
      // Disparamos un evento para notificar que se seleccionó un stock
      this.dispatch('stockSelected', { detail: suggestion });
    });
  }

  // Búsqueda con Solr para el typeahead
  queryStocks(query, syncResults, asyncResults) {
    $.getJSON('/search/query', { q: query }, function(data) {
      asyncResults(data);
    });
  }

  // Método para obtener la referencia seleccionada
  getSelectedReference() {
    return this.selectedReferenceValue;
  }

  disconnect() {
    $(this.inputTarget).typeahead('destroy');
  }
}