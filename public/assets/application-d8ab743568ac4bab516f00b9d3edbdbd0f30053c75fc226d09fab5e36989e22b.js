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

import { Application } from "@hotwired/stimulus"
import EditableController from "./controllers/editable_controller"

// Inicia Stimulus y registra el controlador
const application = Application.start()
application.register("editable", EditableController);
