# frozen_string_literal: true

class ScanResultSerializer
  include JSONAPI::Serializer
  set_type :scan_result
  attributes :ticker, :signals
end
