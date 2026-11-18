# frozen_string_literal: true

require 'spec_helper'
require 'tableau_api/client'

describe TableauApi::Client do
  describe '.resources' do
    it 'returns all available resource classes' do
      resources = described_class.resources

      expect(resources[:auth]).to eq(TableauApi::Resources::Auth)
      expect(resources[:flows]).to eq(TableauApi::Resources::Flows)
      expect(resources[:projects]).to eq(TableauApi::Resources::Projects)
      expect(resources[:sites]).to eq(TableauApi::Resources::Sites)
      expect(resources[:users]).to eq(TableauApi::Resources::Users)
      expect(resources[:groups]).to eq(TableauApi::Resources::Groups)
      expect(resources[:workbooks]).to eq(TableauApi::Resources::Workbooks)
      expect(resources[:datasources]).to eq(TableauApi::Resources::Datasources)
      expect(resources[:jobs]).to eq(TableauApi::Resources::Jobs)
    end

    it 'has 9 resources' do
      expect(described_class.resources.keys.count).to eq(9)
    end
  end

  describe '#initialize' do
    it 'stores host' do
      client = described_class.new(host: 'https://tableau.example.com', site_name: 'Default', username: 'user', password: 'pass')
      expect(client.host).to eq('https://tableau.example.com')
    end

    it 'stores site_name' do
      client = described_class.new(host: 'https://tableau.example.com', site_name: 'TestSite', username: 'user', password: 'pass')
      expect(client.site_name).to eq('TestSite')
    end

    it 'stores username' do
      client = described_class.new(host: 'https://tableau.example.com', site_name: 'Default', username: 'testuser', password: 'pass')
      expect(client.username).to eq('testuser')
    end

    it 'stores password' do
      client = described_class.new(host: 'https://tableau.example.com', site_name: 'Default', username: 'user', password: 'secretpass')
      expect(client.password).to eq('secretpass')
    end

    it 'stores personal access token credentials' do
      client = described_class.new(
        host: 'https://tableau.example.com',
        site_name: 'Default',
        personal_access_token_name: 'my-token',
        personal_access_token_secret: 'token-secret'
      )
      expect(client.personal_access_token_name).to eq('my-token')
      expect(client.personal_access_token_secret).to eq('token-secret')
    end

    it 'uses default API version when not specified' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )
      expect(client.connection.instance_variable_get(:@api_version)).to eq('3.7')
    end

    it 'accepts custom API version' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass',
        api_version: '3.14'
      )
      expect(client.connection.instance_variable_get(:@api_version)).to eq('3.14')
    end

    it 'rejects nil host' do
      expect { described_class.new(host: nil, site_name: 'Default', username: 'user', password: 'pass') }
        .to raise_error('host is required')
    end

    it 'rejects empty host' do
      expect { described_class.new(host: '', site_name: 'Default', username: 'user', password: 'pass') }
        .to raise_error('host is required')
    end

    it 'rejects nil site_name' do
      expect { described_class.new(host: 'https://example.com', site_name: nil, username: 'user', password: 'pass') }
        .to raise_error('site_name is required')
    end

    it 'rejects empty site_name' do
      expect { described_class.new(host: 'https://example.com', site_name: '', username: 'user', password: 'pass') }
        .to raise_error('site_name is required')
    end
  end

  describe '#authentication_type' do
    it 'returns personal access token type when token is provided' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        personal_access_token_name: 'token',
        personal_access_token_secret: 'secret'
      )
      expect(client.authentication_type).to eq(described_class::AUTH_TYPE_PERSONAL_ACCESS_TOKEN)
    end

    it 'returns trusted ticket type when only username is provided' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user'
      )
      expect(client.authentication_type).to eq(described_class::AUTH_TYPE_TRUSTED_TICKET)
    end

    it 'returns username/password type when both are provided' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )
      expect(client.authentication_type).to eq(described_class::AUTH_TYPE_USERNAME_AND_PASSWORD)
    end
  end

  describe '#method_missing' do
    it 'returns a resource instance for known resources' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )

      expect(client.users).to be_an_instance_of(TableauApi::Resources::Users)
      expect(client.projects).to be_an_instance_of(TableauApi::Resources::Projects)
    end

    it 'caches resource instances' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )

      users1 = client.users
      users2 = client.users

      expect(users1).to be(users2)
    end

    it 'raises NoMethodError for unknown methods' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )

      expect { client.unknown_method }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to_missing?' do
    it 'returns true for known resource names' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )

      expect(client.respond_to?(:users)).to be(true)
      expect(client.respond_to?(:projects)).to be(true)
    end

    it 'returns false for unknown methods' do
      client = described_class.new(
        host: 'https://example.com',
        site_name: 'Default',
        username: 'user',
        password: 'pass'
      )

      expect(client.respond_to?(:unknown_method)).to be(false)
    end
  end
end
