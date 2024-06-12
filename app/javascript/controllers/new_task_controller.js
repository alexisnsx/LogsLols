import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-task"
export default class extends Controller {
  static targets = ["newcontent", "form", "content"]

  connect() {
    console.log(this.contentTarget);
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
  }

  // when clicking on the button
  // pop up appears
  // create form appears

  openCreate() {
    this.newcontentTarget.classList.add("active")

    const url = '/tasks/new'
    fetch(url, {
      headers: { 'Accept': 'text/plain' }
    })
    .then(response => response.text())
    .then((data) => {
      this.newcontentTarget.innerHTML = data ;
      document.addEventListener("click", this.handleDocumentClick);
    })
  }


  closeCreate() {
    this.newcontentTarget.classList.remove("active")
  }

  // listens to submit button on form
  // prevents default action

  submit(e) {
    e.preventDefault()
    fetch(this.formTarget.action, {
      method: this.formTarget.method,
      headers: { "Accept": "application/json" },
      body: new FormData(this.formTarget)
    })
    .then(response => response.json())
    .then((data) => {
      console.log(data);
      // if (data.inserted_item) {
        this.insertformTarget.insertAdjacentHTML("afterbegin", data.inserted_item)
      //   this.newcontentTarget.classList.remove("active")
      // }
      // this.formTarget.outerHTML = data.form

      // if data.inserted_item
      // elsif data.updated_form
      // insert back into the content target
      // this.originalcontent()
    })
  }


  // to close the card anywhere on the page

  close() {
    this.newcontentTarget.classList.remove("active")
    document.removeEventListener("click", this.handleDocumentClick)
  }

  handleDocumentClick(event) {
    // Check if the click happened outside the popup and open button
    if (!this.newcontentTarget.contains(event.target)) {
      this.close()
    }
  }

}
