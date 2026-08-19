require "test_helper"

class DeprecationReportingTest < Minitest::Test
  def setup
    @original_report_exception = Denkungsart::Production.report_exception
    @reported_exceptions = []
    Denkungsart::Production.report_exception = lambda do |level, error, payload|
      @reported_exceptions << { level: level, error: error, payload: payload }
    end

    @listeners_before = ActiveSupport::Notifications.notifier.listeners_for("deprecation.prestage")
    run_deprecation_initializer
  end

  def teardown
    added_listeners = ActiveSupport::Notifications.notifier.listeners_for("deprecation.prestage") - @listeners_before
    added_listeners.each { |listener| ActiveSupport::Notifications.unsubscribe(listener) }
    Denkungsart::Production.report_exception = @original_report_exception
  end

  def test_reports_rails_and_application_deprecations
    ActiveSupport::Notifications.instrument("deprecation.rails", message: "Rails warning")
    ActiveSupport::Notifications.instrument("deprecation.prestage", message: "Prestage warning")
    ActiveSupport::Notifications.instrument("unrelated", message: "Other event")

    assert_equal ["Rails warning", "Prestage warning"], @reported_exceptions.pluck(:payload).pluck(:message)
    assert @reported_exceptions.all? { |report| report.values_at(:level, :error) == [:error, "Deprecation Warning"] }
  end

  private
    def run_deprecation_initializer
      active_support_config = Struct.new(:deprecation).new
      app = Struct.new(:config).new(Struct.new(:active_support).new(active_support_config))
      initializer = Denkungsart::Production::Engine.initializers.find do |candidate|
        candidate.name == "denkungsart-production.deprecation_report"
      end

      initializer.run(app)
    end
end
