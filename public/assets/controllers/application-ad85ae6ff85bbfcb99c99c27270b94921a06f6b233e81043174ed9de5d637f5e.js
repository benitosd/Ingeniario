import { Application } from "@hotwired/stimulus"

import DeleteController from "../../app/javascript/controllers/delete_controller.js"

const application = Application.start()
application.register("delete", DeleteController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application };
