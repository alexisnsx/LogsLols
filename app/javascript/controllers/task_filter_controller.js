import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task-filter"
export default class extends Controller {

  static targets = ["results"]


  connect() {
    console.log("Hello from our task filter controller");
  }

  filterTask(event) {
    console.log(event.currentTarget.value)
    fetch(`filter?sort=${event.currentTarget.value}`,{
      headers: {
        Accept: "application/json",
      }
    })
    .then(response => response.json())
    .then((data) => {
      console.log(data)
      this.resultsTarget.innerHTML = data.task_cards
    })
  }
}
