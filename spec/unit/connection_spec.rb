# frozen_string_literal: true

require 'spec_helper'
require 'tableau_api/connection'

describe TableauApi::Connection do
  let(:client) do
    double('TableauApi::Client',
           host: 'https://tableau.example.com',
           auth: double('Auth', token: 'test-token'))
  end

  subject(:connection) { described_class.new(client) }

  describe '#initialize' do
    it 'accepts a client' do
      expect { described_class.new(client) }.not_to raise_error
    end

    it 'uses default API version' do
      connection = described_class.new(client)
      expect(connection.instance_variable_get(:@api_version)).to eq('3.7')
    end

    it 'accepts custom API version' do
      connection = described_class.new(client, api_version: '3.14')
      expect(connection.instance_variable_get(:@api_version)).to eq('3.14')
    end
  end

  describe '#url_for' do
    it 'builds correct URL with leading slash' do
      url = connection.send(:url_for, '/auth/signin')
      expect(url).to eq('https://tableau.example.com/api/3.7/auth/signin')
    end

    it 'builds correct URL without leading slash' do
      url = connection.send(:url_for, 'auth/signin')
      expect(url).to eq('https://tableau.example.com/api/3.7/auth/signin')
    end
  end

  describe '#auth_headers' do
    it 'adds X-Tableau-Auth header' do
      headers = connection.send(:auth_headers, {})
      expect(headers['X-Tableau-Auth']).to eq('test-token')
    end

    it 'preserves existing headers' do
      existing_headers = { 'Content-Type' => 'application/xml' }
      headers = connection.send(:auth_headers, existing_headers)

      expect(headers['Content-Type']).to eq('application/xml')
      expect(headers['X-Tableau-Auth']).to eq('test-token')
    end
  end

  describe '#post' do
    it 'makes POST request to correct endpoint' do
      expect(described_class).to receive(:post)
        .with('https://tableau.example.com/test/path', {})
        .and_return(double('Response', code: '200'))

      connection.post('test/path')
    end
  end
end
