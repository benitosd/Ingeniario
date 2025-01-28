
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "jquery";
import "jquery_ujs";
import "@popperjs/core";
import "bootstrap";
import "@fortawesome/fontawesome-free";
import "my_script";
import "flatpickr"
import "corejs-typeahead"
import "chartkick"
import { Chart } from "chart.js"

// Registrar los componentes necesarios de Chart.js
Chart.register(...Chart.registerables);
