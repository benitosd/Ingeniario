import { Application } from "@hotwired/stimulus"
import EditableController from "./editable_controller"
import DeleteController from "./delete_controller"

application.register("editable", EditableController)
application.register("delete", DeleteController)
const application = Application.start()


// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application };
