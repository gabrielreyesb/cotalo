import { application } from "@hotwired/stimulus"
import { registerControllers } from "@hotwired/stimulus-loading"

// Register all controllers in the controllers directory
registerControllers(application, import.meta.globEager("./**/*_controller.js"))

export { application }
