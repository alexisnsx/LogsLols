import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task-cards"
export default class extends Controller {
  static targets = ["content", "checkbox", "form", "newcontent", "insertform"]
  static values = { id: String };

  connect() {
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
  console.log(e.currentTarget.action, e.currentTarget.method);
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
  //   console.log(data);


  //   // if data.inserted_item
  //   // elsif data.updated_form
  //   // insert back into the content target
  //   // this.originalcontent()
  })
}


// copy new-task over
// check if submit beforebegin works.

/**
   * showing more details of the card
   * when pressing the button on the small card,
   * document add class of active to make it bigger
   * document fetches the new display to display.
   */
openCard(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  cardActive.classList.add("active")
  console.log(cardActive.innerHTML);
  // const cardContent = e.currentTarget.closest('.card-wrapper')
  const url = `/tasks/${cardActive.dataset.id}`
  fetch (url, { headers: {
    "Accept": "text/plain" },
  })
  .then(response => response.text())
  .then((data) => {
    cardActive.innerHTML = data
  })
  // document.addEventListener("click", this.handleDocumentClick);
}

// press the button on the form itself
// card should be able to close
// card should go back to original content

closeCard(e) {
  const cardActive = e.currentTarget.closest('div[data-id]')
  cardActive.classList.remove("active")
  const id = cardActive.dataset.id
  this.getOriginalContent(id, cardActive)
  // managed to fetch data
  // where do data go
  // inside card content
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

// update the form once it is edited
// need to listen to submit and fetch the patch details
// update form accordingly
// update this.originalContent so that form remains the same no matter what.

// update(e) {
//   e.preventDefault()
//   fetch(this.formTarget.action, {
//     method: 'PATCH',
//     headers: {
//       "Accept": "text/plain"
//     },
//     body: new FormData(this.formTarget)
//   })
//   .then(response => response.text())
//   .then((data) => {
//     this.contentTarget.classList.remove("active")
//     this.contentTarget.innerHTML = data
//     // this.contentTarget.outerHTML = data
//     this.originalContent = data
//   })
// }


// to close the card anywhere on the page

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

// to make sure check box is corrected
// need to replace from this.originalContent too

toggleCheckbox(event) {
  const url = `/tasks/${this.idValue}/completion`
  fetch(url, {
    method: 'PATCH',
    headers: {
      "X-CSRF-Token": this.csrfToken,
      "Accept": "text/plain"
    }
  })
  .then(response => response.text())
  .then((data) => {
    // console.log(this.checkboxTarget);
    this.checkboxTarget.outerHTML = data
    // this.originalContent.replace(this.checkboxTarget, data)

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
