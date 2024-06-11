import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sliding-effect"
export default class extends Controller {
  static targets = ["content", "checkbox", "form"]
  static values = { id: String };

  connect() {
    this.originalContent = this.contentTarget.innerHTML
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.csrfToken = document.head.querySelector("[name~=csrf-token][content]").content;
  }

  // showing more details of the card
  // when pressing the button on the small card,
  // document add class of active to make it bigger
  // document fetches the new display to display.


  openCard() {
    this.contentTarget.classList.add("active")

    const url = `/tasks/${this.idValue}`
    fetch (url, { headers: {
      "Accept": "text/plain" },
    })
    .then(response => response.text())
    .then((data) => {
      this.contentTarget.innerHTML = data
      // console.log(data);
    })
    document.addEventListener("click", this.handleDocumentClick);
  }

  // press the button on the form itself
  // card should be able to close
  // card should go back to original content

  closeCard() {
    this.contentTarget.classList.remove("active")
    this.contentTarget.innerHTML = this.originalContent
  }

  // load edit page
  // press the icon, card should zoom in
  // fetch form from edit and display on the card.

  openEdit() {
    console.log(this.contentTarget.innerHTML);
    this.contentTarget.classList.add("active")

    const url = `/tasks/${this.idValue}/edit`
    fetch (url, { headers: {
      "Accept": "text/plain" },
    })
    .then(response => response.text())
    .then((data) => {
      this.contentTarget.innerHTML = data
    })
    document.addEventListener("click", this.handleDocumentClick);
  }

  // close edit form by pressing the arrow button on the inside
  // card should minimize
  // card should go back to original content

  closeEdit() {
    console.log('can close');
    this.contentTarget.classList.remove("active")
    this.contentTarget.innerHTML = this.originalContent
  }

  // update the form once it is edited
  // need to listen to submit and fetch the patch details
  // update form accordingly
  // update this.originalContent so that form remains the same no matter what.

  update(e) {
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
      console.log(this.originalContent);
      console.log(data);
      this.contentTarget.classList.remove("active")
      this.contentTarget.innerHTML = data
      // this.contentTarget.outerHTML = data
      this.originalContent = data
    })
  }

  // brings you to edit form from 'more details' page

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
    if (event.currentTarget.className.contains('fa-regular')) {
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

// ideally toggling open/close should have 2 controllers so that the method isn't too long / confusing

// should do the togglecheckbox on the backend instead
// checking the backend status if it is 'completed' or 'incomplete'
// checking on the backend is better than being dependant on a class name.
// backend should get the data to check if it's working or not
// ideally the response should bring back the partial so that we can replace the icon on front end.
// innerHTML.replace('fa-regular', 'fa-solid')
// original content.replace('fa-regular', 'fa-solid')
