import { Application } from "@hotwired/stimulus"
import text_search_controller from "./text_search_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
