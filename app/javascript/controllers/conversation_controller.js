import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="conversation"
export default class extends Controller {
  static targets = ["prompt", "response"]

  connect() {
    console.log("connected!");
  }

  generateResponse(event) {
    event.preventDefault()
    this.#createLabel('You')
    this.#createMessage(this.promptTarget.value)
    this.#createLabel('AI')
    this.currentContent = this.#createMessage("")
    this.#setupEventSource()
    this.promptTarget.value = ""
  }

  #createLabel(text) {
    const label = document.createElement('strong')
    label.innerText = `${text}`
    this.responseTarget.appendChild(label)
  }

  #createMessage(text) {
    const contentElement = document.createElement('pre') // pre element preserves spaces and line breaks
    contentElement.classList.add('text-break')
    contentElement.innerText = `${text}`
    this.responseTarget.appendChild(contentElement)
    return contentElement
  }

  #setupEventSource() {
    this.eventSource = new EventSource(`/conversation_responses?prompt=${this.promptTarget.value}`)
    this.eventSource.addEventListener("message", this.#handleMessage.bind(this))
    this.eventSource.addEventListener("error", this.#handleError.bind(this)) // we get this error event automatically once the server closes the connection
  }

  #handleMessage(event) {
    const parsedData = JSON.parse(event.data)
    this.currentContent.innerHTML += parsedData.message
    this.responseTarget.scrollTop = this.responseTarget.scrollHeight
  }

  #handleError(event) {
    if (event.eventPhase === EventSource.CLOSED) { // check that the server really did close the connection
      this.eventSource.close() // then close the eventsource on the client
    }
  }

  disconnect() {
    if (this.eventSource) { // if event source somehow still open, close it!!
      this.eventSource.close()
    }
  }
}
