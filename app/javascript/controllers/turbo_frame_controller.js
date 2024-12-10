import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    // Remove or comment out the console.log
    // console.log("TurboFrame controller connected", this.urlValue)
  }

  navigate() {
    console.log("Navigate called with URL:", this.urlValue)
    if (this.urlValue) {
      window.Turbo.visit(this.urlValue)
    }
  }
} 