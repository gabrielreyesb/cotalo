import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.style.cursor = "pointer"
  }

  click(event) {
    const url = this.element.dataset.url
    if (url) {
      Turbo.visit(url)
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
} 