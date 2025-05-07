# frozen_string_literal: true

# Provides markdown/HTML definitions for each indicator
module IndicatorDefinitions
  DEFINITIONS = {
    "rsi" => "**RSI (Relative Strength Index):** Measures momentum. Bullish if crossing above 30; bearish if below 70. [Source](https://www.tradingheroes.com/rsi-divergence-explained/)",
    "macd" => "**MACD:** Trend-following momentum indicator. Bullish when MACD > Signal. [Source](https://www.investopedia.com/articles/forex/05/macddiverge.asp)",
    "ttm_squeeze" => "**TTM Squeeze:** Identifies periods of low volatility that may lead to breakouts. [Source](https://www.schwab.com/learn/story/ttm-squeeze-indicator-technical-signals-traders)",
    "volume_spike" => "**Volume Spike:** Detects unusually high trading volume. [Source](https://theforexgeek.com/volume-spike-indicator/)",
    "ma_ribbon" => "**Moving Average Ribbon:** Uses multiple EMAs to show trend direction. [Source](https://howtotrade.com/indicators/moving-average-ribbon/)"
  }.freeze

  def self.fetch(indicator)
    DEFINITIONS[indicator]
  end
end
