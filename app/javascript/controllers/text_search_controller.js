import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  // static values = {
  //   text: String
  // }
  static targets = ["search", "results", "sort"]

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

  sortTasks(e) {
    // this.sortTargets.forEach(checkbox => {
    //   checkbox.checked = false
    // })

    // e.currentTarget.checked = !e.currentTarget.checked
    e.currentTarget.classList.toggle("checked")
    let url = `/search?q=${this.searchTarget.value}`

    if(!e.currentTarget.classList.contains("checked")) {
      e.currentTarget.checked = false
    } else {
      url += `&sorted=${e.currentTarget.value}`
    }

    fetch(url,{
      headers: {
        Accept: "application/json",
      }
    })
    .then(response => response.json())
    .then((data) => {
      this.resultsTarget.innerHTML = data.task_cards
    })
  }
}
