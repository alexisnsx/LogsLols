import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";

// Connects to data-controller="datepicker"
export default class extends Controller {
  static targets = [ "duedatepickr", "reminderpickr" ]

  connect() {
    flatpickr(this.duedatepickrTarget, {
      dateFormat: "Y-m-d"
    });
    flatpickr(this.reminderpickrTarget, {
      enableTime: true,
      dateFormat: "Y-m-d, H:i"
    })
  }
}
