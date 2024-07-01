require "denkungsart/production/engine"
require "denkungsart/production/version"

module Denkungsart
  module Production
    mattr_accessor :report_exception
    self.report_exception = lambda do |level, msg, extra = {}|
      Rollbar.public_send(level, msg, extra)
    end
  end
end
