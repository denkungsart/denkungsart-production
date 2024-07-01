require "denkungsart/production/engine"
require "denkungsart/production/version"

module Denkungsart
  module Production
    mattr_accessor :error_reporting
    self.error_reporting = :rollbar

    def self.report_exception(level, error, extra = {})
      case error_reporting
      when :rollbar
        Rollbar.public_send(level, error, extra)
      when :sentry
        capture_method = error.is_a?(Exception) ? :capture_exception : :capture_message

        Sentry.public_send(capture_method, error, extra: extra, level: level)
      else
        raise "Don't know how to handle '#{error_reporting}'"
      end
    end
  end
end
