class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :txn

  validates :date, :account, :txn, :amount_cents, presence: true
  validate :date_cannot_be_in_the_future

  after_initialize :set_defaults

  scope :for_product, -> (uuid) { uuid.present? ? where(product_uuid: uuid) : all }
  scope :as_of, -> (date) { where("date <= ?", date) }

  def self.amounts_by_day(start_date:, end_date: Date.current, for_product: nil)
    by_date(start_date: start_date, end_date: end_date, for_product: for_product)
      .each_with_object({}) do |entry, amounts|
        amounts[entry.date] = entry.total_amount
      end
  end

  def self.by_date(start_date:, end_date: Date.current, for_product: nil)
    for_product(for_product).
      where(date: start_date..end_date).
      group(:date).
      select("date, sum(amount_cents) as total_amount")
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
