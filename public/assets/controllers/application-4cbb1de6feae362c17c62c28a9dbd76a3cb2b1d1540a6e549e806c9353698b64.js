import { Application } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Importa tus controladores directamente
import EditableController from "./editable_controller"
import DeleteController from "./delete_controller"

// Inicializa Stimulus
const application = Application.start()

// Registra tus controladores
application.register("editable", EditableController)
application.register("delete", DeleteController);
