# frozen_string_literal: true

require "test_helper"

class TickersControllerTest < ActionDispatch::IntegrationTest
  test "scan returns signals for valid ticker" do
    post "/scan", params: { ticker: "BTCUSDT" }, as: :json
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["signals"]
    assert json["ticker"] == "BTCUSDT"
  end

  test "scan returns error for invalid ticker" do
    post "/scan", params: { ticker: "INVALID" }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert json["error"]
  end
end
