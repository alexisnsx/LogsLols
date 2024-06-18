import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task-filter"
export default class extends Controller {

  static targets = ["results", "priority", "status", "dueDate"]


  connect() {
    console.log("Hello from our task filter controller");
  }


/**
 Object.keys(params).forEach((key)=> {
  filters[]
 })

 */

  filterTask(event) {
    const filter = {}
    if (this.priorityTarget.value !='None'){
      filter.priority = this.priorityTarget.value
    }
    if (this.statusTarget.value !='None'){
      filter.status = this.statusTarget.value
    }
    if (this.dueDateTarget.value){
      filter.dueDate = this.dueDateTarget.value
    }
    console.log(this.priorityTarget.value)
    console.log(this.statusTarget.value)
    console.log(this.dueDateTarget.value)
    fetch(`filter?` + new URLSearchParams(filter),{
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
