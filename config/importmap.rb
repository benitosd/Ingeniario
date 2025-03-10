# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@fortawesome/fontawesome-free", to: "@fortawesome--fontawesome-free.js" # @6.5.2
# From "jquery-rails" gem
pin "jquery" # @3.7.1
pin "jquery_ujs", to: "jquery_ujs.js", preload: true

# From "bootstrap" gem
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

# Use all.js instead of fontawesome.js
#pin "@fortawesome/fontawesome-free", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.1.2/js/all.js"

# Custom JS
pin "my_script", to: "my_script.js", preload: true
pin "stimulus-flatpickr" # @1.4.0
pin "flatpickr" # @4.6.13
pin "stimulus" # @3.2.2
pin "corejs-typeahead" # @1.3.4
pin "process" # @2.0.1
pin "rails-ujs" # @5.2.8

pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4

pin "chartkick", to: "chartkick.js" # Esto buscará en vendor/javascript
pin "chart.js", to: "chart.umd.min.js" # Esto buscará en vendor/javascript
pin "html5-qrcode", to: "html5-qrcode.js" 
#pin "html5-qrcode", to: "https://ga.jspm.io/npm:html5-qrcode@2.3.8/html5-qrcode.min.js"
#pin "@nathanvda/cocoon", to: "cocoon.js"
