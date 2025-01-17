import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const filtersForm = document.getElementById('filtersCollapse')
    if (filtersForm.style.display === 'none' || !filtersForm.style.display) {
      filtersForm.style.display = 'block'
    } else {
      filtersForm.style.display = 'none'
    }
  }
} 