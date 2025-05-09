class TickersController < ApplicationController
  # GET / (dashboard)
  def index
    # Renders the main dashboard view
  end

  # POST /scan (AJAX/Hotwire)
  def scan
    ticker = params[:ticker].to_s.upcase.strip
    timeframes = params[:timeframes] || %w[15m 1h 2h 4h 24h 48h 1w 1mo]
    @result = IndicatorScanService.new(ticker:, timeframes:).call

    respond_to do |format|
      format.turbo_stream do
        if @result[:error]
          render turbo_stream: turbo_stream.replace("scan_results", partial: "tickers/error", locals: { error: @result[:error] })
        else
          render turbo_stream: turbo_stream.replace("scan_results", partial: "tickers/scan_results", locals: { result: @result })
        end
      end
      
      format.json do
        if @result[:error]
          render json: { error: @result[:error] }, status: :unprocessable_entity
        else
          render json: ScanResultSerializer.new(@result).serializable_hash, status: :ok
        end
      end
    end
  end

  # GET /definitions/:indicator
  def definitions
    indicator = params[:indicator]
    # This could fetch markdown from a file or constant
    definition = IndicatorDefinitions.fetch(indicator)
    if definition
      render json: { definition: }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end
end
