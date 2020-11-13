# Denkungsart::Production

This is a row of initializers we use in all our apps in production.

### denkungsart-production.setup-lograge
Enable lograge for denser logs (so papertrail doesn't go over quota)

### denkungsart-production.basic_auth
Set up basic auth if the `BASIC_AUTH` env variable is set. It is expected to be formatted like `user:password`.

### denkungsart-production.i18n_rollbar
Reports missing translations as errors to Rollbar.

### denkungsart-production.unpermitted_parameters_rollbar
Reports unpermitted parameters as errors to Rollbar.

### denkungsart-production.deprecation_rollbar
Reports rails deprecation warnings as errors to Rollbar.

### denkungsart-production.disable_rack_timeout_logging
Disables `rack-timeout`-logging. It's very verbose, and we don't use it.

### denkungsart-production.rollbar_ignore_bots
Don't report errors caused by bots to Rollbar.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'denkungsart-production', group: :production
```

## Changelog
### 2020-11-13
* Don't report errors caused by bots to Rollbar

### 2020-09-22
* Disable `rack-timeout`-logging

### 2019-10-16
* Report missing translations when using ActionView::TranslationHelper shortcuts

### 2019-08-20
* Report missing translations as errors instead of warning.

### 2019-06-13
* Initial extraction

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
