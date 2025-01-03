import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Set initial value
    if (this.element.value) {
      const cleanValue = this.element.value.replace(/[^\d.-]/g, '');
      this.element.dataset.rawValue = cleanValue;
      
      // Format for display if not readonly
      if (!this.element.readOnly) {
        this.element.value = cleanValue;
      }
    }
  }

  input(event) {
    // Remove non-numeric characters except decimal point and minus
    let value = event.target.value.replace(/[^\d.-]/g, '');
    
    // Store raw value for calculations
    event.target.dataset.rawValue = value;
    
    // Update display value
    event.target.value = value;
  }

  getValue() {
    return parseFloat(this.element.dataset.rawValue || this.element.value) || 0;
  }
} 