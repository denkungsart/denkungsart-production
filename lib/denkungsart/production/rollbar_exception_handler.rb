class RollbarExceptionHandler < I18n::ExceptionHandler
  def call(exception, locale, key, options)
    report_exception(exception, locale, key, options) if exception.is_a?(I18n::MissingTranslation::Base)
    super
  end

  def report_exception(exception, locale, key, options)
    Rollbar.error(exception, locale: locale, key: key, options: options)
  end
end
