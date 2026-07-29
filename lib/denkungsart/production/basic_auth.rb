require "rack/auth/basic"

module Denkungsart
  module Production
    class BasicAuth < Rack::Auth::Basic
      def initialize(app)
        super do |user, password|
          user == Denkungsart::Production.basic_auth_user &&
            password == Denkungsart::Production.basic_auth_password
        end
      end

      def call(env)
        if excluded_path?(env["PATH_INFO"])
          @app.call(env)
        else
          super
        end
      end

      private

      def excluded_path?(path)
        Denkungsart::Production.basic_auth_excluded_paths.include?(path)
      end
    end
  end
end
