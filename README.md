# CryptoScreen

A dark-themed, mobile-responsive Rails 7.1 app for scanning crypto and stock tickers for technical indicator confluence, with TradingView charting and localStorage favorites. No database required for core features.

## Quickstart (3 Commands)

```sh
bin/setup           # Installs Ruby, Node, gems, JS, and sets up credentials
bin/dev             # Starts Rails + JS + CSS in development mode
open http://localhost:3000  # Visit the app in your browser
```

## API Docs

Interactive OpenAPI docs: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

## Test & Lint

```sh
bin/rake test       # Run all tests (ViewComponent, request, system)
bin/rubocop         # Check code style
```

## Features

- Ticker validation (Binance, Alpha Vantage, Finnhub)
- Indicator grid (RSI, MACD, TTM Squeeze, Volume Spike, MA Ribbon)
- Multi-timeframe scan (15m–1mo)
- Confluence alerts
- TradingView chart embed
- Favorites via browser localStorage
- Responsive, dark UI (Tailwind)
- API versioned under /v1, documented with OpenAPI (RSwag)

See CONTRIBUTING.md for PR etiquette and development guidelines.
