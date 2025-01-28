
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
import Chart from "chart.js"

// Registrar los componentes necesarios de Chart.js
Chart.register(...Chart.registerables)

// Configuración global de Chartkick
document.addEventListener('turbo:load', () => {
  window.Chartkick.configure({
    colors: ["#4f46e5", "#06b6d4", "#10b981", "#f59e0b"],
    library: {
      plugins: {
        legend: {
          position: 'bottom'
        }
      }
    }
  })
});
