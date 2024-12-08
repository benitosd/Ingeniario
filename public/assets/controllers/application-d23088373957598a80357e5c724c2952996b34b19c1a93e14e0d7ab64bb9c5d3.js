import { Application } from "@hotwired/stimulus"
application.register("modal", ModalController)
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application };
