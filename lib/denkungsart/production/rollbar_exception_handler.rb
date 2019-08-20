class RollbarExceptionHandler < I18n::ExceptionHandler
  def call(exception, locale, key, options)
    if exception.is_a?(I18n::MissingTranslation)
      Rollbar.error(exception, locale: locale, key: key, options: options)
    end
    super
  end
end
