# frozen_string_literal: true

# Renders the indicator grid: indicators × timeframes, color-coded for bullish/bearish, with confluence highlights
class IndicatorGridComponent < ViewComponent::Base
  # @param signals [Hash] { timeframe => { indicator => :bullish/:bearish/nil } }
  # @param timeframes [Array<String>]
  # @param indicators [Array<String>]
  def initialize(signals:, timeframes:, indicators:)
    @signals = signals
    @timeframes = timeframes
    @indicators = indicators
  end

  def confluence_badges
    # Returns array of [type, label] for confluence (≥3 bullish/bearish on tf or indicator)
    badges = []
    @timeframes.each do |tf|
      bullish = @indicators.count { |ind| @signals.dig(tf, ind) == :bullish }
      bearish = @indicators.count { |ind| @signals.dig(tf, ind) == :bearish }
      if bullish >= 3
        badges << [ :bullish, "🔥 Triple-Stack Bullish on #{tf}" ]
      elsif bearish >= 3
        badges << [ :bearish, "❄️ Triple-Stack Bearish on #{tf}" ]
      end
    end
    @indicators.each do |ind|
      bullish = @timeframes.count { |tf| @signals.dig(tf, ind) == :bullish }
      bearish = @timeframes.count { |tf| @signals.dig(tf, ind) == :bearish }
      if bullish >= 3
        badges << [ :bullish, "🔥 #{ind.upcase} Bullish ≥3 TFs" ]
      elsif bearish >= 3
        badges << [ :bearish, "❄️ #{ind.upcase} Bearish ≥3 TFs" ]
      end
    end
    badges
  end
end
