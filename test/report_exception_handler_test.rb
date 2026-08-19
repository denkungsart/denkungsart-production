require "test_helper"

class ReportExceptionHandlerTest < Minitest::Test
  def setup
    @original_exception_handler = I18n.exception_handler
    @original_report_exception = Denkungsart::Production.report_exception
    @reported_exceptions = []

    Denkungsart::Production.report_exception = lambda do |level, error, context|
      @reported_exceptions << { level: level, error: error, context: context }
    end
    run_i18n_initializer
  end

  def teardown
    I18n.exception_handler = @original_exception_handler
    Denkungsart::Production.report_exception = @original_report_exception
  end

  def test_action_view_reports_a_missing_translation_once
    result = ActionView::Base.empty.t("missing.translation")

    assert_match(/translation missing/, result)
    assert_equal 1, @reported_exceptions.size
    assert_instance_of I18n::MissingTranslation, @reported_exceptions.first[:error]
    assert_equal "missing.translation", @reported_exceptions.first.dig(:context, :key)
  end

  private
    def run_i18n_initializer
      initializer = Denkungsart::Production::Engine.initializers.find do |candidate|
        candidate.name == "denkungsart-production.i18n_report"
      end

      initializer.run
    end
end
