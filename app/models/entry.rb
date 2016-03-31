class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :txn

  validates :date, :account, :txn, :amount_cents, presence: true
  validate :date_cannot_be_in_the_future

  after_initialize :set_defaults

  scope :for_product, -> (uuid) { uuid.present? ? where(product_uuid: uuid) : all }
  scope :as_of, -> (date) { where("date <= ?", date) }
  scope :between, -> (date_range) { where(date: date_range) }

  def self.net_credits_by_day(as_of: Date.current, for_product: nil)
    net_credits_by_date.for_product(for_product).as_of(as_of)
      .each_with_object({}) do |entry, amounts|
        amounts[entry.date] = entry.total_amount
      end
  end

  def self.net_credits_by_date
    group(:date).
    select("date, sum(#{type_query}) as total_amount")
  end

  def self.net_credits
    sum(type_query)
  end

  private

  def self.type_query
    "CASE WHEN type = 'Entries::Credit' THEN amount_cents ELSE -amount_cents END"
  end

  def date_cannot_be_in_the_future
    if self.date.present? && self.date > Date.current
      errors.add(:date, I18n.t('entry.errors.date_in_future'))
    end
  end

  def set_defaults
    self.date ||= Date.current
  end
end
