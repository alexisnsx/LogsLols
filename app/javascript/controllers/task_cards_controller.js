import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task-cards"
export default class extends Controller {
  static targets = ["content", "checkbox", "newcontent", "insertform"]
  static values = { id: String };

  connect() {
    this.csrfToken = document.head.querySelector("[name~=csrf-token][content]").content;
    // this.handleDocumentClick = this.handleDocumentClick.bind(this);
}

  openCreate() {
    this.newcontentTarget.classList.add("active")

    const url = '/tasks/new'
    fetch(url, {
      headers: { 'Accept': 'text/plain' }
    })
    .then(response => response.text())
    .then((data) => {
      this.newcontentTarget.innerHTML = data ;
    })
  }


  closeCreate() {
    this.newcontentTarget.classList.remove("active")
  }

// listens to submit button on form
// prevents default action

submit(e) {
  e.preventDefault()
  const cardActive = e.currentTarget.closest('div[data-id]')

  fetch(e.currentTarget.action, {
    method: e.currentTarget.method,
    headers: { "Accept": "application/json" },
    body: new FormData(e.currentTarget)
  })
  .then(response => response.json())
  .then((data) => {
    if (data.inserted_item) {
      this.insertformTarget.insertAdjacentHTML("afterbegin", data.inserted_item)
      this.newcontentTarget.classList.remove("active")
    } else if (data.updated_form) {
      cardActive.classList.remove("active")
      cardActive.innerHTML = data.updated_form
    }
  })
}

/**
   * showing more details of the card
   * when pressing the button on the small card,
   * document add class of active to make it bigger
   * document fetches the new display to display.
   */
openCard(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  cardActive.classList.add("active")
  const url = `/tasks/${cardActive.dataset.id}`
  fetch (url, { headers: {
    "Accept": "text/plain" },
  })
  .then(response => response.text())
  .then((data) => {
    cardActive.innerHTML = data
  })
  // document.addEventListener("click", this.handleDocumentClick(e));
}

// press the button on the form itself
// card should be able to close
// card should go back to original content

closeCard(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  cardActive.classList.remove("active")
  const id = cardActive.dataset.id
  this.getOriginalContent(id, cardActive)
}

// load edit page
// press the icon, card should zoom in
// fetch form from edit and display on the card.

openEdit(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  cardActive.classList.add("active")

  const url = `/tasks/${cardActive.dataset.id}/edit`
  fetch (url, { headers: {
    "Accept": "text/plain" },
  })
  .then(response => response.text())
  .then((data) => {
    cardActive.innerHTML = data;
  })
  // document.addEventListener("click", this.handleDocumentClick);
}

// close edit form by pressing the arrow button on the inside
// card should minimize
// card should go back to original content

closeEdit(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  cardActive.classList.remove("active")
  const id = cardActive.dataset.id
  this.getOriginalContent(id, cardActive)
}


// to make sure check box is corrected
// need to replace from this.originalContent too

toggleCheckbox(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  const id = cardActive.dataset.id
  const eventTarget = e.currentTarget
  // console.log(e.currentTarget.outerHTML);
  // take event target closest div = checkbox.
  const url = `/tasks/${cardActive.dataset.id}/completion`
  fetch(url, {
    method: 'PATCH',
    headers: {
      "X-CSRF-Token": this.csrfToken,
      "Accept": "text/plain"
    }
  })
  .then(response => response.text())
  .then((data) => {
    const toUpdate = eventTarget.closest('.task-icons')
    toUpdate.outerHTML = data
    // cardActive.innerHTML = this.getOriginalContent(id, cardActive)
  })
}

getOriginalContent(id, cardActive) {
  const url = `/tasks/${id}/original`
  fetch (url, { headers: {
    "Accept": "text/plain" },
  })
  .then(response => response.text())
  .then((data) => {
    cardActive.innerHTML = data;
  })
}

delete(e) {
  e.preventDefault()
  const cardActive = e.currentTarget.closest('div[data-id]')
  if(confirm('Are you sure')) {
    const eventTarget = e.currentTarget
    const url = `/tasks/${cardActive.dataset.id}`
    fetch(url, {
      method: 'DELETE',
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/plain"
      }
    })
    .then(response => response.text())
    .then((data) => {
      const toDelete = eventTarget.closest('.col-4')
      toDelete.parentElement.removeChild(toDelete)
      document.body.insertAdjacentHTML("beforeend", data)
    })
  }
}

// to close the card anywhere on the page

// close(e) {
//   const cardActive = e.currentTarget.closest('div[data-id]')
//   cardActive.classList.remove("active")
//   // this.resetContent()
//   document.removeEventListener("click", this.handleDocumentClick(e))
// }

// handleDocumentClick(e) {
//   // Check if the click happened outside the popup and open button
//   const cardActive = e.currentTarget.closest('div[data-id]')
//   if (!cardActive.contains(e.target)) {
//     this.close(e)
//   }
// }

// resetContent(e) {
//   // change the original content
//   const cardActive = e.currentTarget.closest('div[data-id]')
//   cardActive.innerHTML = this.getOriginalContent()
// }

}
