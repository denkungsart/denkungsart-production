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
    deprecator("Rails").warn("Rails warning")
    deprecator("Prestage").warn("Prestage warning")
    ActiveSupport::Notifications.instrument("unrelated", message: "Other event")

    assert_equal ["DEPRECATION WARNING: Rails warning", "DEPRECATION WARNING: Prestage warning"], @reported_exceptions.pluck(:error).map(&:message)
    assert @reported_exceptions.all? { |report| report[:level] == :error }
    assert @reported_exceptions.all? { |report| report[:error].is_a?(Denkungsart::Production::DeprecationWarning) }
    assert_equal ["Rails", "Prestage"], @reported_exceptions.pluck(:payload).pluck(:gem_name)
  end

  def test_reports_the_caller_in_the_backtrace_only
    deprecator = deprecator("Prestage")
    deprecated_method(deprecator)
    deprecated_method(deprecator)

    assert_equal ["DEPRECATION WARNING: Use bar instead"] * 2, @reported_exceptions.pluck(:error).map(&:message)
    assert_equal [__LINE__ - 4, __LINE__ - 3], @reported_exceptions.map { |report| report[:error].backtrace.first[/:(\d+):/, 1].to_i }
    assert @reported_exceptions.none? { |report| report[:payload].key?(:callstack) }
  end

  private
    def deprecator(gem_name)
      ActiveSupport::Deprecation.new("1.x", gem_name).tap { |deprecator| deprecator.behavior = :notify }
    end

    def deprecated_method(deprecator)
      deprecator.warn("Use bar instead")
    end

    def run_deprecation_initializer
      active_support_config = Struct.new(:deprecation).new
      app = Struct.new(:config).new(Struct.new(:active_support).new(active_support_config))
      initializer = Denkungsart::Production::Engine.initializers.find do |candidate|
        candidate.name == "denkungsart-production.deprecation_report"
      end

      initializer.run(app)
    end
end
