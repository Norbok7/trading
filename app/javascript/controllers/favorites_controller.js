import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.load();
  }

  load() {
    const favorites = JSON.parse(localStorage.getItem("favorites") || "[]");
    // TODO: Render favorites dropdown
  }

  toggle(event) {
    const input = document.querySelector('input[name="ticker"]');
    if (!input) return;
    const ticker = input.value.toUpperCase();
    let favorites = JSON.parse(localStorage.getItem("favorites") || "[]");
    if (favorites.includes(ticker)) {
      favorites = favorites.filter((f) => f !== ticker);
    } else {
      favorites.push(ticker);
    }
    localStorage.setItem("favorites", JSON.stringify(favorites));
    this.load();
  }
}
