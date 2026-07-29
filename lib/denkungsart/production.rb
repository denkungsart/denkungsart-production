require "denkungsart/production/engine"
require "denkungsart/production/version"

module Denkungsart
  module Production
    mattr_accessor :report_exception
    self.report_exception = lambda do |level, error, extra = {}|
      error = RuntimeError.new(error) unless error.is_a?(Exception)
      Rails.error.report(error, severity: level, context: extra)
    end

    mattr_accessor :basic_auth_user
    self.basic_auth_user = nil

    mattr_accessor :basic_auth_password
    self.basic_auth_password = nil

    mattr_accessor :basic_auth_excluded_paths
    self.basic_auth_excluded_paths = []

    def self.basic_auth_credentials=(credentials)
      self.basic_auth_user, self.basic_auth_password = credentials
    end
  end
end
