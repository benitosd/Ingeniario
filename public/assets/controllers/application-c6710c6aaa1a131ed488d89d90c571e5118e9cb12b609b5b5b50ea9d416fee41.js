import { Application } from "@hotwired/stimulus"
import EditableController from "./editable_controller"
import DeleteController from "./delete_controller"


const application = Application.start()

application.register("editable", EditableController)
application.register("delete", DeleteController)
;
