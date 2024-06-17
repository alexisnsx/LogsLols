import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  // static values = {
  //   text: String
  // }
  static targets = ["search", "results", "sort"]

  connect() {
    console.log("Hello from our text search controller");
  }

  searchTask(event) {
    console.log(this.searchTarget.value);
    fetch(`/search?q=${this.searchTarget.value}`,{
      headers: {
        Accept: "application/json",
      }
    })
    .then(response => response.json())
    .then((data) => {
      console.log(data)
      this.resultsTarget.innerHTML = data.task_cards
      // data.Search.forEach((result) => {
      //   const textTag = `<li class="list-group-item border-0">
      //   </li>`
      //   this.resultsTarget.insertAdjacentHTML("beforeend", textTag)
      // })
    })
  }

  sortTasks() {
    console.log(this.searchTarget.value);
    console.log(this.sortTargets);

    // 1. get the clicked value - what is sorted
    const clicked = this.sortTargets.find((element) => element.checked);
    console.log(clicked)
    // 2. fetch based on sorted and search parameters

    // 3. [backend] sort tasks
    fetch(`/search?q=${this.searchTarget.value}&sorted=${clicked.value}`,{
      headers: {
        Accept: "application/json",
      }
    })
    .then(response => response.json())
    .then((data) => {
      console.log(data)
      this.resultsTarget.innerHTML = data.task_cards
      // data.Search.forEach((result) => {
      //   const textTag = `<li class="list-group-item border-0">
      //   </li>`
      //   this.resultsTarget.insertAdjacentHTML("beforeend", textTag)
      // })
    })
  }
}
