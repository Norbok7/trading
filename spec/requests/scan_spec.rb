require 'swagger_helper'

RSpec.describe 'Scan API', type: :request do
  path '/v1/scan' do
    post 'Scan indicators for a ticker' do
      tags 'Scan'
      consumes 'application/json'
      parameter name: :scan, in: :body, schema: {
        type: :object,
        properties: {
          ticker: { type: :string, example: 'BTCUSDT' },
          timeframes: { type: :array, items: { type: :string }, example: %w[1h 4h] }
        },
        required: ['ticker']
      }
      response '200', 'scan result' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string },
                attributes: {
                  type: :object,
                  properties: {
                    ticker: { type: :string },
                    signals: { type: :object }
                  }
                }
              }
            }
          }
        run_test!
      end
      response '422', 'invalid ticker' do
        schema type: :object, properties: { error: { type: :string } }
        run_test!
      end
    end
  end
end