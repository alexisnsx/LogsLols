import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content", "truncate"]

  connect() {

  }

  toggleSlide() {
    console.log(this.contentTarget);
    // console.log(this.hereTarget.innerHTML)
    // this.contentTarget.classList.toggle("effect");
    this.contentTarget.classList.toggle("task-show-card")
    // this.hereTarget.innerHTML = this.contentTarget.innerHTML
    // this.contentTarget.classList.toggle("d-none")
    // this.hereTarget.classList.toggle("effect")
    // this.hereTarget.classList.toggle("effect")


  }
}

// on click
// add class of transform
// tranform accordingly
// transform: translateX for sliding
// append dimmed page to bodyhtml
// append this.contentTarget into HTML
