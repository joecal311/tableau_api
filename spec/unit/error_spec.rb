# frozen_string_literal: true

require 'spec_helper'
require 'tableau_api/error'

describe TableauApi::TableauError do
  let(:mock_response) do
    double('Net::HTTPResponse', code: '404', body: error_xml)
  end

  let(:error_xml) do
    <<-XML
      <tsResponse xmlns="http://tableau.com/api">
        <error code="404005">
          <summary>Resource Not Found</summary>
          <detail>Project 'foo' could not be found.</detail>
        </error>
      </tsResponse>
    XML
  end

  describe '#initialize' do
    it 'parses error code, summary, and detail from XML response' do
      error = TableauApi::TableauError.new(mock_response)

      expect(error.http_response_code).to eq('404')
      expect(error.error_code).to eq('404005')
      expect(error.summary).to eq('Resource Not Found')
      expect(error.detail).to eq("Project 'foo' could not be found.")
    end

    it 'formats error message correctly' do
      error = TableauApi::TableauError.new(mock_response)

      expect(error.message).to eq('404005: Resource Not Found; Project \'foo\' could not be found.')
    end

    it 'uses default error when tsResponse is missing from XML' do
      missing_tsresponse_xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <not-tsResponse></not-tsResponse>
      XML
      no_tsresponse = double('Net::HTTPResponse', code: '500', body: missing_tsresponse_xml)
      error = TableauApi::TableauError.new(no_tsresponse)

      expect(error.http_response_code).to eq('500')
      expect(error.error_code).to eq(1_000)
      expect(error.summary).to eq('Tableau API response was missing')
    end
  end
end
