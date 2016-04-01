module DefaultDate
  extend ActiveSupport::Concern

  included do
    validate :date_cannot_be_in_the_future
    after_initialize :set_defaults
  end

  private

  def date_cannot_be_in_the_future
    if self.date.present? && self.date > Date.current
      errors.add(:date, I18n.t('entry.errors.date_in_future'))
    end
  end

  def set_defaults
    self.date ||= Date.current
  end
end
