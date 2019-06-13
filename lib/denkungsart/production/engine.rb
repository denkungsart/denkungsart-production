require "rails/engine"
require "lograge"
require "rollbar"
require "denkungsart/production/rollbar_exception_handler"

module Denkungsart
  module Production
    class Engine < ::Rails::Engine
      # Enable lograge for denser logs (so papertrail doesn't go over quota)
      initializer "denkungsart-production.setup-lograge" do |app|
        app.config.lograge.enabled = true
        app.config.lograge.custom_options = lambda do |event|
          {
            params: event.payload[:params].except("controller", "action", "format")
          }
        end
        app.config.lograge.custom_payload do |controller|
          {
            uid: controller.current_user.try(:id) || :guest
          }
        end
      end

      # Set up basic auth if ENV variable is set
      initializer "denkungsart-production.basic_auth" do |app|
        if ENV["BASIC_AUTH"]
          expected_user, expected_password = ENV["BASIC_AUTH"].split(":")
          app.config.middleware.use(::Rack::Auth::Basic) do |user, password|
            user == expected_user && password == expected_password
          end
        end
      end

      # Log missing translations to Rollbar
      initializer "denkungsart-production.i18n_rollbar" do
        I18n.exception_handler = RollbarExceptionHandler.new
      end

      # Log unpermitted parameters to Rollbar
      initializer "denkungsart-production.unpermitted_parameters_rollbar", before: "action_controller.parameters_config" do |app|
        app.config.action_controller.action_on_unpermitted_parameters = :log
        ActiveSupport::Notifications.subscribe "unpermitted_parameters.action_controller" do |_name, _start, _finish, _id, payload|
          Rollbar.error("Unpermitted Parameters", payload)
        end
      end

      # Log deprecation warnings to Rollbar
      initializer "denkungsart-production.deprecation_rollbar", before: "active_support.deprecation_behavior" do |app|
        app.config.active_support.deprecation = :notify

        ActiveSupport::Notifications.subscribe "deprecation.rails" do |_name, _start, _finish, _id, payload|
          Rollbar.error("Deprecation Warning", payload)
        end
      end
    end
  end
end
