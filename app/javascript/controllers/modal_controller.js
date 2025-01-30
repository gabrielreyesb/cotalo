import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Initialize modal when controller connects
    this.modal = new bootstrap.Modal(this.element)
  }

  open() {
    this.modal.show()
  }

  close() {
    this.modal.hide()
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  closeBackground(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
} 