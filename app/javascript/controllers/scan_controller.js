import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "input", "grid", "alerts", "widget"];

  submit(event) {
    event.preventDefault();
    const form = event.target;
    const data = new FormData(form);
    // Get CSRF token from meta tag
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    
    fetch("/scan", {
      method: "POST",
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": token
      },
      body: data,
    })
      .then(response => {
        if (response.ok) {
          return response.text().then(html => {
            // Process successful response
            Turbo.renderStreamMessage(html);
            const ticker = form.querySelector('input[name="ticker"]').value.toUpperCase();
            setTimeout(() => this.updateTradingView(ticker), 100);
          });
        } else {
          // Handle HTTP error responses (like 422, 500)
          return response.text().then(html => {
            try {
              // Try to parse as Turbo stream
              Turbo.renderStreamMessage(html);
            } catch (e) {
              // If not a valid Turbo stream, show a generic error
              this.showError(`Error: ${response.statusText}`);
              console.error("Response error:", html);
            }
          });
        }
      })
      .catch(error => {
        // Handle network errors
        this.showError(`Network error: ${error.message}`);
        console.error("Fetch error:", error);
      });
  }

  showError(msg) {
    alert(msg); // TODO: Replace with toast
  }

  renderGrid(data) {
    // TODO: Render indicator grid and confluence alerts
  }

  updateTradingView(ticker) {
    const widgetDiv = document.getElementById("tradingview-widget-inner");
    if (!widgetDiv) return;
    widgetDiv.innerHTML = "";
    const script = document.createElement("script");
    script.src = "https://s3.tradingview.com/tv.js";
    script.onload = () => {
      // eslint-disable-next-line no-undef
      new TradingView.widget({
        symbol: ticker + "USDT",
        container_id: "tradingview-widget-inner",
        width: "100%",
        height: 400,
        theme: "dark",
        style: "1",
        locale: "en",
        hide_top_toolbar: true,
        hide_legend: false,
        allow_symbol_change: true,
        autosize: true,
      });
    };
    document.body.appendChild(script);
  }
}
