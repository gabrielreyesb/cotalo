import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Initialize Bootstrap 4 dropdown
    $(this.element).dropdown({
      hover: false,
      autoClose: true
    });
  }

  disconnect() {
    $(this.element).dropdown('dispose');
  }

  // Close dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      $(this.element).dropdown('hide');
    }
  }
} 