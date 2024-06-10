import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content"]
  static values = { id: String };

  connect() {
    this.originalContent = this.contentTarget.innerHTML
    this.isOriginal = true
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
  }

  async toggleSlide() {
    this.contentTarget.classList.toggle("active");
    const url = `/tasks/${this.idValue}`

    if (this.isOriginal) {
      try {
        const response = await fetch(url , {
          headers: { 'Accept': 'text/html'
          }
        });
        if (response.ok) {
          const newContent = await response.text();
          this.contentTarget.innerHTML = newContent
          this.contentTarget.scrollTop = this.contentTarget.scrollHeight
        } else {
          console.error("Failed to load new content");
        }
      } catch (error) {
        console.error("Error fetching new content", error);
      }
    } else {
      this.contentTarget.innerHTML = this.originalContent;
    }
    document.addEventListener("click", this.handleDocumentClick);
    this.isOriginal = !this.isOriginal;
  }

  async loadEdit() {
    this.contentTarget.classList.toggle("active");
    const url = `/tasks/${this.idValue}/edit`

    if (this.isOriginal) {
      try {
        const response = await fetch(url , {
          headers: { 'Accept': 'text/html'
          }
        });
        if (response.ok) {
          const newContent = await response.text();
          this.contentTarget.innerHTML = newContent
        } else {
          console.error("Failed to load new content");
        }
      } catch (error) {
        console.error("Error fetching new content", error);
      }
    } else {
      this.contentTarget.innerHTML = this.originalContent;
    }
    this.isOriginal = !this.isOriginal;
  }

  close() {
    this.contentTarget.classList.remove("active")
    this.resetContent()
    document.removeEventListener("click", this.handleDocumentClick)
  }

  handleDocumentClick(event) {
    // Check if the click happened outside the popup and open button
    if (!this.contentTarget.contains(event.target)) {
      this.close()
    }
  }

  resetContent() {
    this.contentTarget.innerHTML = this.originalContent
  }
}



// on click
// add class of transform
// tranform accordingly
// transform: translateX for sliding
// append dimmed page to bodyhtml
// append this.contentTarget into HTML
