import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.style.cursor = "pointer"
  }

  click(event) {
    const url = this.element.dataset.url
    Turbo.visit(url)
  }
} 