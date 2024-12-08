import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "corejs-typeahead"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    $(this.inputTarget).typeahead(
      {
        hint: true,
        highlight: true,
        minLength: 1
      },
      {
        name: 'items',
        source: this.queryItems.bind(this),
        displayKey: 'email'
      }
    );
  }

  queryItems(query, syncResults, asyncResults) {
    $.getJSON('/search/query', { q: query }, function(data) {
      
      asyncResults(data);
    });
  }
};
