module ReportMissingTranslationInTranslationHelper
  def t(key, options = {})
    translate(key, options.reverse_merge(raise: true))
  rescue I18n::MissingTranslationData => e
    I18n.exception_handler.report_exception(e, e.locale, e.key, e.options)
    translate(key, options)
  end
end
