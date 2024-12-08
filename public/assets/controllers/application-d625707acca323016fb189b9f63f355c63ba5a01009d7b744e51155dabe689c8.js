import { Application } from "@hotwired/stimulus"

import DeleteController from "../javascript/controller/delete_controller"

const application = Application.start()
application.register("delete", DeleteController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application };
