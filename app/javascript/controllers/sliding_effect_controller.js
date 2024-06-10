import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content", "checkbox"]
  static values = { id: String };

  connect() {
    this.originalContent = this.contentTarget.innerHTML
    this.isOriginal = true
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.csrfToken = document.head.querySelector("[name~=csrf-token][content]").content;
    console.log(this.contentTarget);
  }

  async toggleSlide() {
    this.contentTarget.classList.toggle("active");
    const url = `/tasks/${this.idValue}`

    if (this.isOriginal) {
      try {
        const response = await fetch(url , {
          headers: { 'Accept': 'text/plain'
          }
        });
        if (response.ok) {
          const newContent = await response.text();
          this.contentTarget.innerHTML = newContent
          // TODO: find a way to scroll this shit
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
          headers: { 'Accept': 'text/plain'
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
    document.addEventListener("click", this.handleDocumentClick);
    this.isOriginal = !this.isOriginal;
  }

  async changeEdit() {
    console.log("changed");
    const url = `/tasks/${this.idValue}/edit`

    const response = await fetch(url, {
      headers: { 'Accept': 'text/plain'
      }
    })
    const newContent = await response.text();
    this.contentTarget.innerHTML = newContent
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
