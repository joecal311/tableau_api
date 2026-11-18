# Code Quality Improvement Plan

## Overview
This document outlines improvements to raise the `tableau_api` gem to modern Ruby gem standards.

## 1. Move Development Dependencies to Gemfile

### Rationale
Modern Ruby gems follow the convention of specifying development dependencies in the `Gemfile`, not the gemspec. This allows easier testing with different dependency versions.

### Changes
- **File**: `Gemfile`
- **File**: `tableau_api.gemspec`

### Implementation
```ruby
# Gemfile - add after line 4
group :development, :test do
  gem 'pry', '~> 0.14'
  gem 'pry-byebug', '~> 3.10'
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.13'
  gem 'rubocop', '~> 1.85'
end

group :test do
  gem 'chunky_png', '~> 1.3'
  gem 'vcr', '~> 6.4'
  gem 'webmock', '~> 3.26'
end
```

### Gemspec Changes
Remove these lines from `tableau_api.gemspec`:
```ruby
spec.add_development_dependency 'chunky_png', '~> 1.3'
spec.add_development_dependency 'pry', '~> 0.14'
spec.add_development_dependency 'pry-byebug', '~> 3.10'
spec.add_development_dependency 'rake', '~> 13.0'
spec.add_development_dependency 'rspec', '~> 3.13'
spec.add_development_dependency 'rubocop', '~> 1.85'
spec.add_development_dependency 'vcr', '~> 6.4'
spec.add_development_dependency 'webmock', '~> 3.26'
```

---

## 2. Add GitHub Actions CI

### Rationale
Travis CI has deprecated free open-source testing. GitHub Actions is the modern standard with better integration.

### Changes
- **New File**: `.github/workflows/ci.yml`

### Implementation
```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
          bundler-cache: true
      - run: bundle exec rubocop

  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ruby: ['4.0', '3.4', '3.3']
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
      - name: Run unit tests only (integration tests require Tableau server)
        run: bundle exec rspec --exclude-pattern '**/resources/*_spec.rb'
```

---

## 3. Make API Version Configurable

### Rationale
Tableau may release new API versions. Hardcoding `3.7` makes future upgrades harder.

### Changes
- **File**: `lib/tableau_api/client.rb`
- **File**: `lib/tableau_api/connection.rb`
- **File**: `lib/tableau_api/client_spec.rb` (new tests)

### Implementation
```ruby
# lib/tableau_api/connection.rb
module TableauApi
  class Connection
    DEFAULT_API_VERSION = '3.7'
    
    def initialize(client, api_version: DEFAULT_API_VERSION)
      @client = client
      @api_version = api_version
    end
    
    # ... rest of class
  end
end
```

```ruby
# lib/tableau_api/client.rb
class Client
  def initialize(host:, site_name:, api_version: Connection::DEFAULT_API_VERSION, **options)
    @connection = Connection.new(self, api_version: api_version)
    # ... rest of initialization
  end
end
```

---

## 4. Add Unit Tests for Core Classes

### Rationale
The current test suite only has 5 unit tests. Core classes like `Client`, `Connection`, and `TableauError` lack coverage.

### Changes
- **New File**: `spec/unit/connection_spec.rb`
- **New File**: `spec/unit/error_spec.rb`
- **New File**: `spec/unit/client_spec.rb`

### Unit Test Strategy
- Mock HTTP responses at the connection level
- Test business logic without network calls
- Keep VCR/integration tests separate for full integration testing

### Example Structure
```
spec/
  unit/
    connection_spec.rb    # Test API methods, pagination, URL building
    error_spec.rb       # Test error parsing and message formatting
    client_spec.rb      # Test initialization and delegation
  resources/
    # Existing integration specs (require Tableau server)
```

---

## 5. Improve URL Construction Safety

### Rationale
String interpolation for URLs can lead to issues with edge cases. URI.join provides proper URL handling.

### Changes
- **File**: `lib/tableau_api/connection.rb`

### Implementation
```ruby
require 'uri'

class Connection
  def url_for(path)
    base = "#{@client.host}/api/#{@api_version}"
    uri = URI.parse(base)
    uri.path = File.join(uri.path, path.sub(%r{^/}, ''))
    uri.to_s
  end
end
```

---

## 6. RuboCop Configuration Cleanup

### Changes
- **File**: `.rubocop.yml`

Remove the now-unnecessary `Gemspec/DevelopmentDependencies: false` line after moving deps to Gemfile.

---

## Implementation Order

1. **Phase 1**: Move dev dependencies to Gemfile (low risk, high impact)
2. **Phase 2**: Add GitHub Actions CI (improves development workflow)
3. **Phase 3**: Add unit tests (improves confidence)
4. **Phase 4**: Make API version configurable (feature enhancement)
5. **Phase 5**: Improve URL construction (security hardening)

---

## Estimated Effort

| Phase | Complexity | Time |
|-------|------------|------|
| 1 | Low | 10 min |
| 2 | Low | 15 min |
| 3 | Medium | 2-3 hours |
| 4 | Medium | 30 min |
| 5 | Low | 15 min |
