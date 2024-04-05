require "rails/engine"
require "lograge"
require "rollbar"
require "voight_kampff"
require "denkungsart/production/rollbar_exception_handler"
require "denkungsart/production/report_missing_translation_in_translation_helper"

module Denkungsart
  module Production
    class Engine < ::Rails::Engine
      initializer "denkungsart-production.setup-lograge" do |app|
        app.config.lograge.enabled = true
        app.config.lograge.custom_options = lambda do |event|
          info = {
            params: event.payload[:params].except("controller", "action", "format")
          }
          info.merge!(event.payload[:custom]) if event.payload[:custom]
          info
        end
        app.config.lograge.custom_payload do |controller|
          {
            uid: controller.current_user.try(:id) || :guest
          }
        end
      end

      initializer "denkungsart-production.basic_auth" do |app|
        if ENV["BASIC_AUTH"]
          expected_user, expected_password = ENV["BASIC_AUTH"].split(":")
          app.config.middleware.use(::Rack::Auth::Basic) do |user, password|
            user == expected_user && password == expected_password
          end
        end
      end

      initializer "denkungsart-production.i18n_rollbar" do
        I18n.exception_handler = RollbarExceptionHandler.new
        ActiveSupport.on_load(:action_view) do
          prepend ReportMissingTranslationInTranslationHelper
        end
      end

      initializer "denkungsart-production.unpermitted_parameters_rollbar", before: "action_controller.parameters_config" do |app|
        app.config.action_controller.action_on_unpermitted_parameters = :log
        ActiveSupport::Notifications.subscribe "unpermitted_parameters.action_controller" do |_name, _start, _finish, _id, payload|
          Rollbar.error("Unpermitted Parameters", payload)
        end
      end

      initializer "denkungsart-production.deprecation_rollbar", before: "active_support.deprecation_behavior" do |app|
        app.config.active_support.deprecation = :notify

        ActiveSupport::Notifications.subscribe "deprecation.rails" do |_name, _start, _finish, _id, payload|
          Rollbar.error("Deprecation Warning", payload)
        end
      end

      initializer "denkungsart-production.disable_rack_timeout_logging" do
        Rack::Timeout::Logger.disable if defined?(Rack::Timeout::Logger)
      end

      initializer "denkungsart-production.rollbar_ignore_bots" do
        ignore_bots = proc do |options|
          scope = options[:scope]
          user_agent = scope[:request]&.dig(:headers, "User-Agent")
          raise Rollbar::Ignore if VoightKampff.bot?(user_agent)
        end
        Rollbar.configuration.before_process << ignore_bots
      end
    end
  end
end
