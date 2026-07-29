# Denkungsart::Production

This is a row of initializers we use in all our apps in production.

### denkungsart-production.setup-lograge
Enable lograge for denser logs (so papertrail doesn't go over quota)

### denkungsart-production.basic_auth
Set up basic auth in the host application's `config/environments/production.rb`. As a general rule,
configuration used by gem initializers should be set in the environment config rather than in
`config/initializers`, so it is available before the gem initializers run.

The middleware is only added when both a user and password are configured. Host applications can
source the values from their environment:

```ruby
# config/environments/production.rb
Denkungsart::Production.basic_auth_credentials = ENV["BASIC_AUTH"].split(":")
Denkungsart::Production.basic_auth_excluded_paths = ["/up", "/webhooks/example"]
```

The optional excluded paths are exact request paths which do not require authentication.

### denkungsart-production.i18n_report
Reports missing translations as errors to error reporting.

### denkungsart-production.unpermitted_parameters_report
Reports unpermitted parameters as errors to error reporting.

### denkungsart-production.deprecation_report
Reports rails deprecation warnings as errors to error reporting.

Errors are reported through `Rails.error` by default. Applications can override the reporter:

```ruby
Denkungsart::Production.report_exception = lambda do |level, error, context|
  MyErrorReporter.report(error, level: level, context: context)
end
```

### denkungsart-production.disable_rack_timeout_logging
Disables `rack-timeout`-logging. It's very verbose, and we don't use it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'denkungsart-production', group: :production
```

## Changelog
### 2024-07-01
* Generalize error reporting to not be dependent on Rollbar, but continue to default to Rollbar.
* Add support for Sentry.

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
