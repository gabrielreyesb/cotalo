import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
  static values = {
    message: String,
    type: String
  }

  connect() {
    if (this.hasMessageValue) {
      this.showAlert()
    }
  }

  showAlert() {
    const config = {
      html: this.messageValue,
      icon: this.typeValue,
      confirmButtonText: 'Ok',
      confirmButtonColor: '#28a745',
      customClass: {
        popup: 'swal2-show',
        htmlContainer: 'text-center',
        confirmButton: 'btn btn-success'
      },
      width: '40rem',
      didClose: () => {
        const container = document.getElementById('dynamic-messages')
        if (container) {
          container.innerHTML = ''
        }
      }
    }

    Swal.fire(config).then(() => {
      const container = document.getElementById('dynamic-messages')
      if (container) {
        container.innerHTML = ''
      }
    })
  }
}