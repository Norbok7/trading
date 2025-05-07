# frozen_string_literal: true

require "test_helper"

class IndicatorGridComponentTest < ViewComponent::TestCase
  def test_renders_grid_with_signals_and_confluence
    signals = {
      "1h" => { rsi: :bullish, macd: :bullish, ttm_squeeze: :bullish, volume_spike: nil, ma_ribbon: nil },
      "4h" => { rsi: :bearish, macd: nil, ttm_squeeze: nil, volume_spike: :bearish, ma_ribbon: :bearish }
    }
    timeframes = %w[1h 4h]
    indicators = %w[rsi macd ttm_squeeze volume_spike ma_ribbon]
    render_inline(IndicatorGridComponent.new(signals:, timeframes:, indicators:))
    assert_selector "table"
    assert_text "RSI"
    assert_text "MACD"
    assert_selector ".bg-green-500", count: 3
    assert_selector ".bg-red-500", count: 2
    assert_text "🔥 Triple-Stack Bullish on 1h"
    assert_text "❄️ Triple-Stack Bearish on 4h"
  end
end
