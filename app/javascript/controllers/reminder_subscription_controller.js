import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { userId: Number }
  static targets = ["reminders"]

  connect() {
    this.subscription = createConsumer().subscriptions.create(
      { channel: "ReminderChannel", id: this.userIdValue },
      // { received: data => this.remindersTarget.insertAdjacentHTML("beforeend", data) }
      { received: data => console.log(data)}
    )
    console.log(`Subscribed to the reminder with the id ${this.userIdValue}.`)

    setInterval(()=>{
      console.log('Fetching tasks', new Date());
      fetch("/get_tasks_due");
    }, 30000);
  }

  disconnect() {
    console.log("Unsubscribed from the reminder")
    this.subscription.unsubscribe()
    clearInterval()
  }

}
