# frozen_string_literal: true

require_relative "indicator_helpers"

# Service: Validates ticker, fetches candles, computes indicator signals for all timeframes
class IndicatorScanService
  TIMEFRAMES = {
    "15m" => 15,
    "1h" => 60,
    "2h" => 120,
    "4h" => 240,
    "24h" => 1440,
    "48h" => 2880,
    "1w" => 10080,
    "1mo" => 43200
  }.freeze
  INDICATORS = %w[rsi macd ttm_squeeze volume_spike ma_ribbon].freeze

  def initialize(ticker:, timeframes: TIMEFRAMES.keys)
    @ticker = ticker
    @timeframes = timeframes
  end

  def call
    return { error: "Ticker required" } if @ticker.blank?
    # Validate ticker via API (Alpha Vantage, Finnhub, Binance)
    valid = ::TickerValidator.valid?(@ticker)
    return { error: "Invalid ticker" } unless valid

    signals = {}
    @timeframes.each do |tf|
      candles = CandleFetcher.fetch(@ticker, tf)
      signals[tf] = IndicatorCalculator.new(candles).signals
    end
    { ticker: @ticker, signals: signals }
  rescue => e
    { error: e.message }
  end
end
