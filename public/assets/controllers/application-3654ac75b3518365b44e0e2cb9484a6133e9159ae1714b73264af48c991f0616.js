import { Application } from "@hotwired/stimulus"

// Importa los controladores manualmente
import EditableController from "./editable_controller"
import DeleteController from "./delete_controller"

// Inicializa Stimulus
const application = Application.start()

// Registra los controladores;
