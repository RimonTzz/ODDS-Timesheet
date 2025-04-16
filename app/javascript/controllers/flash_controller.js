import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.innerHTML.trim() !== '') {
      setTimeout(() => {
        this.element.classList.add('fade-out')
        setTimeout(() => {
          this.element.innerHTML = ''
        }, 500)
      }, 3000)
    }
  }
} 