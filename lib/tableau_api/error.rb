# frozen_string_literal: true

module TableauApi
  class TableauError < StandardError
    MISSING_RESPONSE_ERROR = {
      'code' => 1_000,
      'detail' => '',
      'summary' => 'Tableau API response was missing'
    }.freeze

    attr_reader :http_response_code, :error_code, :summary, :detail

    def initialize(net_response)
      @http_response_code = net_response.code
      ts_error = HTTParty::Parser.new(net_response.body, :xml).parse['tsResponse']
      error = ts_error.nil? ? MISSING_RESPONSE_ERROR : ts_error['error']
      @error_code = error['code']
      @summary = error['summary']
      @detail = error['detail']
      super("#{error_code}: #{summary}; #{detail}")
    end
  end
end
