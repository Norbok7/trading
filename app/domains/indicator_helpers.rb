# frozen_string_literal: true

require "net/http"
require "json"

# Stub: Validates ticker existence via free APIs
module TickerValidator
  def self.valid?(ticker)
    return false unless ticker.present? && ticker.match?(/^[A-Z0-9]{2,12}$/)
    url = URI("https://api.binance.com/api/v3/exchangeInfo?symbol=#{ticker.upcase}")
    res = Net::HTTP.get_response(url)
    return false unless res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    data["symbols"]&.any? { |s| s["symbol"] == ticker.upcase }
  rescue StandardError => e
    Rails.logger.warn("Binance symbol validation error: #{e.message}")
    false
  end
end

module CandleFetcher
  BASE_URL = "https://api.binance.com/api/v3/klines".freeze
  # Map app timeframes to Binance intervals
  INTERVALS = {
    "15m" => "15m",
    "1h" => "1h",
    "2h" => "2h",
    "4h" => "4h",
    "24h" => "1d",
    "48h" => "2d",
    "1w" => "1w",
    "1mo" => "1M"
  }.freeze

  def self.fetch(ticker, timeframe)
    cache_key = "candles:#{ticker}:#{timeframe}"
    Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      interval = INTERVALS[timeframe] || "1h"
      url = URI("#{BASE_URL}?symbol=#{ticker.upcase}&interval=#{interval}&limit=100")
      res = Net::HTTP.get_response(url)
      return [] unless res.is_a?(Net::HTTPSuccess)
      data = JSON.parse(res.body)
      data.map do |row|
        {
          open_time:    row[0],
          open:         row[1].to_f,
          high:         row[2].to_f,
          low:          row[3].to_f,
          close:        row[4].to_f,
          volume:       row[5].to_f,
          close_time:   row[6],
          quote_volume: row[7].to_f
        }
      end
    end
  rescue StandardError => e
    Rails.logger.warn("Binance fetch error: #{e.message}")
    []
  end
end

# Stub: Computes indicator signals from candles
class IndicatorCalculator
  RSI_PERIOD = 14
  MACD_FAST = 12
  MACD_SLOW = 26
  MACD_SIGNAL = 9
  TTM_BB_PERIOD = 20
  TTM_KC_PERIOD = 20
  TTM_KC_MULT = 1.5
  VOL_SPIKE_PERIOD = 20
  MA_RIBBON_EMAS = [ 8, 13, 21, 34, 55 ]

  def initialize(candles)
    @candles = candles
  end

  def signals
    {
      rsi: rsi_signal,
      macd: macd_signal,
      ttm_squeeze: ttm_squeeze_signal,
      volume_spike: volume_spike_signal,
      ma_ribbon: ma_ribbon_signal
    }
  end

  private

  def rsi_signal
    closes = @candles.map { |c| c[:close] }
    return nil if closes.size < RSI_PERIOD + 1
    rsi = compute_rsi(closes.last(RSI_PERIOD + 1))
    return :bullish if rsi > 30 && closes[-2] <= 30
    return :bearish if rsi < 70 && closes[-2] >= 70
    nil
  end

  # MACD: Bullish if MACD > Signal, Bearish if MACD < Signal
  def macd_signal
    closes = @candles.map { |c| c[:close] }
    return nil if closes.size < MACD_SLOW + MACD_SIGNAL
    macd_line = ema(closes, MACD_FAST) - ema(closes, MACD_SLOW)
    signal_line = ema([ *closes.last(MACD_SLOW + MACD_SIGNAL) ], MACD_SIGNAL)
    return :bullish if macd_line > signal_line
    return :bearish if macd_line < signal_line
    nil
  end

  # TTM Squeeze: Bullish if histogram turns green after squeeze, Bearish if red
  def ttm_squeeze_signal
    closes = @candles.map { |c| c[:close] }
    highs = @candles.map { |c| c[:high] }
    lows = @candles.map { |c| c[:low] }
    return nil if closes.size < TTM_BB_PERIOD + 1
    bb_upper, bb_lower = bollinger_bands(closes, TTM_BB_PERIOD)
    kc_upper, kc_lower = keltner_channels(closes, highs, lows, TTM_KC_PERIOD, TTM_KC_MULT)
    in_squeeze = bb_upper.last < kc_upper.last && bb_lower.last > kc_lower.last
    hist = closes.last - closes[-2]
    return :bullish if !in_squeeze && hist > 0
    return :bearish if !in_squeeze && hist < 0
    nil
  end

  # Volume Spike: Bullish if close up and vol ≥ 1.5×avg, Bearish if close down and vol spike
  def volume_spike_signal
    closes = @candles.map { |c| c[:close] }
    vols = @candles.map { |c| c[:volume] }
    return nil if vols.size < VOL_SPIKE_PERIOD + 1
    avg_vol = vols.last(VOL_SPIKE_PERIOD).sum / VOL_SPIKE_PERIOD.to_f
    spike = vols.last >= 1.5 * avg_vol
    return :bullish if closes.last > closes[-2] && spike
    return :bearish if closes.last < closes[-2] && spike
    nil
  end

  # MA Ribbon: Bullish if close > majority of EMAs, Bearish if < majority
  def ma_ribbon_signal
    closes = @candles.map { |c| c[:close] }
    return nil if closes.size < MA_RIBBON_EMAS.max + 1
    emas = MA_RIBBON_EMAS.map { |p| ema(closes, p) }
    above = emas.count { |e| closes.last > e }
    below = emas.count { |e| closes.last < e }
    return :bullish if above > MA_RIBBON_EMAS.size / 2
    return :bearish if below > MA_RIBBON_EMAS.size / 2
    nil
  end

  # --- Helper methods ---
  def compute_rsi(closes)
    gains = []
    losses = []
    closes.each_cons(2) do |prev, curr|
      change = curr - prev
      if change.positive?
        gains << change
        losses << 0
      else
        gains << 0
        losses << -change
      end
    end
    avg_gain = gains.last(RSI_PERIOD).sum / RSI_PERIOD.to_f
    avg_loss = losses.last(RSI_PERIOD).sum / RSI_PERIOD.to_f
    return 50.0 if avg_loss.zero?
    rs = avg_gain / avg_loss
    100 - (100 / (1 + rs))
  end

  def ema(data, period)
    return data.last if data.size < period
    k = 2.0 / (period + 1)
    ema = data.first(period).sum / period.to_f
    data.last(data.size - period).each { |v| ema = v * k + ema * (1 - k) }
    ema
  end

  def bollinger_bands(data, period)
    return [ nil, nil ] if data.size < period
    ma = data.last(period).sum / period.to_f
    std = Math.sqrt(data.last(period).map { |v| (v - ma)**2 }.sum / period)
    [ ma + 2 * std, ma - 2 * std ]
  end

  def keltner_channels(closes, highs, lows, period, mult)
    return [ nil, nil ] if closes.size < period
    ma = closes.last(period).sum / period.to_f
    tr = highs.zip(lows, closes).last(period).map { |h, l, c| h - l }
    atr = tr.sum / period.to_f
    [ ma + mult * atr, ma - mult * atr ]
  end
end
