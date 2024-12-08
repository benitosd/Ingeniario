import { Application } from "@hotwired/stimulus"
import DeleteController from "./delete_controller"
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application };
