import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content", "truncate"]

  connect() {

  }

  toggleSlide() {
    this.contentTarget.classList.toggle("active");
    this.contentTarget.innerHTML = "Heee"
    fetch(url)
    
  }
}

// on click
// add class of transform
// tranform accordingly
// transform: translateX for sliding
// append dimmed page to bodyhtml
// append this.contentTarget into HTML
