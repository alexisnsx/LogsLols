import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content", "checkbox", "form"]
  static values = { id: String };

  connect() {
    this.originalContent = this.contentTarget.innerHTML
    this.isOriginal = true
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.csrfToken = document.head.querySelector("[name~=csrf-token][content]").content;
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

    console.log(this.originalContent);
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

  send(e) {
    e.preventDefault()
    fetch(this.formTarget.action, {
      method: 'PATCH',
      headers: {
        "Accept": "text/plain"
      },
      body: new FormData(this.formTarget)
    })
    .then(response => response.text())
    .then((data) => {
      this.contentTarget.outerHTML = data
    })
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
    // change the original content
    this.contentTarget.innerHTML = this.originalContent
  }

  toggleCheckbox(event) {
    const url = `/tasks/${this.idValue}/completion`
    fetch(url, {
      method: 'PATCH',
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/plain"
      }
    })
    // if (event.currentTarget.className.contains('fa-regular')) {
    //   event.currentTarget.className = event.currentTarget.className.replace('fa-regular', 'fa-solid')
    //   const url = `/tasks/${this.idValue}/complete`
    //   fetch(url, {
    //     method: 'PATCH',
    //     headers: {
    //       "X-CSRF-Token": this.csrfToken,
    //       "Accept": "application/json"
    //     }
    //   })
    // } else {
    //   event.currentTarget.className = event.currentTarget.className.replace('fa-solid', 'fa-regular')
    //   const url = `/tasks/${this.idValue}/incomplete`
    //   fetch(url, {
    //     method: 'PATCH',
    //     headers: {
    //       "X-CSRF-Token": this.csrfToken,
    //       "Accept": "application/json"
    //     }
    //   })
    // }
  }
}

// ideally toggling open/close should have 2 controllers so that the method isn't too long / confusing

// should do the togglecheckbox on the backend instead
// checking the backend status if it is 'completed' or 'incomplete'
// checking on the backend is better than being dependant on a class name.
// backend should get the data to check if it's working or not
// ideally the response should bring back the partial so that we can replace the icon on front end.
// innerHTML.replace('fa-regular', 'fa-solid')
// original content.replace('fa-regular', 'fa-solid')


// get task.status value from fronted
