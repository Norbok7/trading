import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "grid", "alerts", "widget"]

  submit(event) {
    event.preventDefault()
    const form = event.target
    const data = new FormData(form)
    fetch("/scan", {
      method: "POST",
      headers: { "Accept": "text/vnd.turbo-stream.html" },
      body: data
    })
      .then(r => r.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
        const ticker = form.querySelector('input[name="ticker"]').value.toUpperCase()
        setTimeout(() => this.updateTradingView(ticker), 100)
      })
  }

  showError(msg) {
    alert(msg) // TODO: Replace with toast
  }

  renderGrid(data) {
    // TODO: Render indicator grid and confluence alerts
  }

  updateTradingView(ticker) {
    const widgetDiv = document.getElementById("tradingview-widget-inner")
    if (!widgetDiv) return
    widgetDiv.innerHTML = ""
    const script = document.createElement("script")
    script.src = "https://s3.tradingview.com/tv.js"
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
        autosize: true
      })
    }
    document.body.appendChild(script)
  }
}