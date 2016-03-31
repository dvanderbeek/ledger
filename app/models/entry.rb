class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :txn

  validates :date, :account, :txn, :amount_cents, presence: true
  validate :date_cannot_be_in_the_future

  after_initialize :set_defaults

  scope :for_product, -> (uuid) { uuid.present? ? where(product_uuid: uuid) : all }
  scope :as_of, -> (date) { where("date <= ?", date) }
  scope :between, -> (date_range) { where(date: date_range) }

  QUERIES = {
    net_credits: "CASE WHEN type = 'Entries::Credit' THEN amount_cents ELSE -amount_cents END",
    amount_cents: "amount_cents"
  }

  def self.by_date(metric, group_by_account: false)
    by_date = group(:date).select(:date, "sum(#{QUERIES[metric]}) as total_amount")
    by_date = by_date.group(:account_id).select(:account_id) if group_by_account
    by_date
  end

  def self.by_day(metric, group_by_account: false)
    by_date(metric, group_by_account: group_by_account).each_with_object({}) do |entry, amounts|
      if group_by_account
        amounts[entry.account_id] ||= {}
        amounts[entry.account_id][entry.date] = entry.total_amount
      else
        amounts[entry.date] = entry.total_amount
      end
    end
  end

  def self.net_credits
    sum(QUERIES[:net_credits])
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
