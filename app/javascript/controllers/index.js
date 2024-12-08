// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import TurboFrameController from "./turbo_frame_controller"
eagerLoadControllersFrom("controllers", application)
application.register("turbo-frame", TurboFrameController)
