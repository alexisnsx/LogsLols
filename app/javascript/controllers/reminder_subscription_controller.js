import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { userId: Number }

  connect() {
    this.subscription = createConsumer().subscriptions.create(
      { channel: "ReminderChannel", id: this.userIdValue },
      {
        received: data => {
          // update the class of all the due tasks
          data.task_ids.forEach(id => {
            const taskElement = document.querySelector(`#task-${id} .tasks-cards`);
            taskElement.classList.add('task-due')
          });

          // set up your flash data
          this.element.innerHTML = data.reminders;

          setTimeout(() => {
            this.element.innerHTML = '';
          }, 5000);
        }
      }
    )
    // setInterval(()=>{
    //   fetch("/get_tasks_due", {
    //     headers: {
    //       Accept: "application/json",
    //     }
    //   });
    // }, 10000);
  }

  disconnect() {
    this.subscription.unsubscribe()
    clearInterval()
  }

}
