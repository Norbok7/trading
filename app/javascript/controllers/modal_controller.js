import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  close() {
    this.element.classList.add("hidden");
  }

  open(content) {
    document.getElementById("indicator-definition-content").innerHTML = content;
    this.element.classList.remove("hidden");
  }
}
