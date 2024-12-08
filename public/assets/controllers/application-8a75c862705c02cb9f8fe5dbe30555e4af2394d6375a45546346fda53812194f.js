import { Application } from "@hotwired/stimulus"
import ModalController from "./controllers/modal_controller"
const application = Application.start()
application.register("modal", ModalController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application };
