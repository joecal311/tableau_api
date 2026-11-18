# Ruby v4 Migration Plan for tableau_api gem

## Current State

| Dependency | Current | Ruby Support |
|------------|---------|--------------|
| httparty | ~> 0.13 | Needs upgrade |
| builder | ~> 3.2 | Likely OK |
| multipart-post | ~> 2.0 | Likely OK |
| rubyzip | >= 1.0 | Likely OK |
| rspec | ~> 3.6 | ~> 3.13 recommended |
| webmock | ~> 3.0 | ~> 3.26 recommended |
| vcr | ~> 6.0 | 6.4.0 recommended |
| rubocop | ~> 1.48.1 | 1.85.x recommended |
| chunky_png | ~> 1.3.11 | Verify |

## Implementation Steps

### Step 1: Update Gemspec (`tableau_api.gemspec`)

- Change `spec.required_ruby_version` to `'>= 2.7'` (already correct, verify)
- Update dependencies:
  - `httparty`: `~> 0.21` (critical upgrade)
  - `builder`: `~> 3.4`
  - `multipart-post`: `~> 2.0` (likely already compatible)
  - `rubyzip`: `>= 2.0`

### Step 2: Update Development Dependencies

- `chunky_png`: `~> 1.3`
- `pry`: `~> 0.14`
- `pry-byebug`: `~> 3.10`
- `rake`: `~> 13.0`
- `rspec`: `~> 3.13`
- `rubocop`: `~> 1.85`
- `vcr`: `~> 6.4`
- `webmock`: `~> 3.26`

### Step 3: Code Review & Testing

Verify these files after HTTParty upgrade:
- `lib/tableau_api/connection.rb` - HTTParty calls
- `lib/tableau_api/resources/workbooks.rb` - Uses `HTTParty::Parser` (may need `require 'httparty/parser'`)
- `lib/tableau_api/error.rb` - Uses `HTTParty::Parser`
- `lib/tableau_api/resources/auth.rb` - Handles `HTTParty::RedirectionTooDeep`

### Step 4: Update CI Configuration

Add Ruby 4.0 to `.travis.yml` test matrix:
```yaml
rvm:
  - 3.3
  - 3.4
  - 4.0
```

### Step 5: Update RuboCop Config

Update `.rubocop.yml` target Ruby version:
```yaml
AllCops:
  TargetRubyVersion: 3.4  # or 4.0 depending on minimum Ruby version
```

### Step 6: Testing

```bash
bundle update
bundle exec rake
```

## Key Changes Summary

| Gem | Current | Recommended | Notes |
|-----|---------|-------------|-------|
| httparty | 0.13 | ~> 0.21 | **Critical upgrade** - kwargs handling |
| rspec | 3.6 | ~> 3.13 | Ruby 4 compatible |
| vcr | 6.0 | ~> 6.4 | Latest stable |
| webmock | 3.0 | ~> 3.26 | Latest stable |
| rubocop | 1.48 | ~> 1.85 | Supports Ruby 4.1 target |

## Notes

- Ruby 4->5 migration is safer than Ruby 2->3 was
- Most gems only need gemspec update, not code changes
- Test thoroughly after dependency updates
