import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="conversation"
export default class extends Controller {
  static targets = ["prompt", "response", "paragraph"]

  connect() {
    console.log("connected!");
    this.csrfToken = document.head.querySelector("[name~=csrf-token][content]").content;
  }

  generateResponse(event) {
    event.preventDefault()
    this.#createLabel('you')
    this.#createMessage(this.promptTarget.value)
    this.#createLabel('assistant')
    this.currentContent = this.#createMessage("")
    this.#setupEventSource()
    this.promptTarget.value = ""
  }

  paragraphTargetConnected(element) {
    console.log(element);
  }

  #createLabel(text) {
    const label = document.createElement('strong')
    label.innerText = `${text}`
    this.responseTarget.appendChild(label)
  }

  #createMessage(text) {
    const contentElement = document.createElement('p') // pre element preserves spaces and line breaks
    contentElement.classList.add('text-break')
    contentElement.dataset.conversationTarget = "paragraph"
    contentElement.innerHTML = `${text}`
    this.responseTarget.appendChild(contentElement)
    this.responseTarget.scrollTop = this.responseTarget.scrollHeight
    return contentElement
  }

  #setupEventSource() {
    this.eventSource = new EventSource(`/conversation_responses?prompt=${this.promptTarget.value}`)
    this.eventSource.addEventListener("message", this.#handleMessage.bind(this))
    this.eventSource.addEventListener("error", this.#handleError.bind(this)) // we get this error event automatically once the server closes the connection
  }

  #htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, "text/html");
    return doc.documentElement.textContent;
  }

  #handleMessage(event) {
    const parsedData = JSON.parse(event.data)
    this.currentContent.innerHTML += parsedData.message
    this.responseTarget.scrollTop = this.responseTarget.scrollHeight

    this.paragraphTargets.forEach(paragraph => {
      if(paragraph.innerHTML.includes("https")) {
        console.log(paragraph.innerHTML);
        paragraph.innerHTML = paragraph.innerHTML
      }
    });
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
