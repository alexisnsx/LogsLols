import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-task"
export default class extends Controller {
  static targets = ["newcontent", "form", "insertform"]

  connect() {
  }

  async addNewTask() {
    this.newcontentTarget.classList.toggle("active")
    const url = '/tasks/new'

    const response = await fetch(url, {
      headers: { 'Accept': 'text/plain'
      }
    });
    const newContent = await response.text();
    this.newcontentTarget.innerHTML = newContent
  }

  send (e) {
    e.preventDefault()
    fetch(this.formTarget.action, {
      method: "POST",
      headers: { "Accept": "application/json" },
      body: new FormData(this.formTarget)
    })
    .then(response => response.json())
    .then((data) => {
      this.formTarget.outerHTML = data.form
      this.newcontentTarget.classList.remove("active")
      debugger
      if (data.inserted_item) {
        this.insertformTarget.insertAdjacentHTML("afterbegin", data.inserted_item)
      }
    })
  }
}
