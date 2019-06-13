# Denkungsart::Production

This is a row of initializers we use in all our apps in production.

### denkungsart-production.setup-lograge
Sets up lograge for denser logs.

### denkungsart-production.basic_auth
Set up basic auth if the `BASIC_AUTH` env variable is set. It is expected to be formatted like `user:password`.

### denkungsart-production.i18n_rollbar
Reports missing translations as warnings to Rollbar.

### denkungsart-production.unpermitted_parameters_rollbar
Reports unpermitted parameters as errors to Rollbar.

### denkungsart-production.deprecation_rollbar
Reports rails deprecation warnings as errors to Rollbar.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'denkungsart-production', group: :production
```

## Changelog
### 0.1.0 (2019-06-13)
* Initial extraction

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
