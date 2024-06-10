import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content", "truncate", "checkbox"]
  static values = { id: String };

  connect() {
    this.originalContent = this.contentTarget.innerHTML
    this.isOriginal = true
    this.csrfToken = document.head.querySelector("[name~=csrf-token][content]").content;
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

  toggleCheckbox(event) {
    if (event.currentTarget.className.includes('fa-regular')) {
      event.currentTarget.className = event.currentTarget.className.replace('fa-regular', 'fa-solid')
      const url = `/tasks/${this.idValue}/complete`
      fetch(url, {
        method: 'PATCH',
        headers: {
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        }
      })
    } else {
      event.currentTarget.className = event.currentTarget.className.replace('fa-solid', 'fa-regular')
      const url = `/tasks/${this.idValue}/incomplete`
      fetch(url, {
        method: 'PATCH',
        headers: {
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        }
      })
    }
  }
}



// on click
// add class of transform
// tranform accordingly
// transform: translateX for sliding
// append dimmed page to bodyhtml
// append this.contentTarget into HTML
