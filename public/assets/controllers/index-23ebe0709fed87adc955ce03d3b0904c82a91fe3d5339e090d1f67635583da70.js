// Import and register all your controllers from the importmap under controllers/*

import { Application } from "@hotwired/stimulus"

// Importa los controladores directamente
import EditableController from "./controllers/editable_controller.js"
import DeleteController from "./controllers/delete_controller.js"

// Inicializa Stimulus
const application = Application.start()

// Registra los controladores manualmente
application.register("editable", EditableController)
application.register("delete", DeleteController)

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application);
