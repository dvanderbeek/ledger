class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :txn

  validates :account, :txn, :amount_cents, presence: true

  scope :for_product, -> (uuid) { uuid.present? ? joins(:txn).where(txns: { product_uuid: uuid }) : all }
  scope :as_of, -> (date) { joins(:txn).where("date <= ?", date) }
  scope :between, -> (date_range) { joins(:txn).where(txns: { date: date_range }) }

  after_create :cache_balances

  delegate :date, to: :txn, prefix: true
  delegate :product_uuid, to: :txn

  QUERIES = {
    amount_cents: "amount_cents",
    net_credits: "CASE WHEN entries.type = 'Entry::Credit' THEN amount_cents ELSE -amount_cents END",
    net_debits: "CASE WHEN entries.type = 'Entry::Debit' THEN amount_cents ELSE -amount_cents END",
  }

  def self.by_date(metric, group_by_account: false)
    handle_error(metric)
    by_date = group(:date).select(:date, "sum(#{QUERIES[metric]}) as total_amount")
    by_date = by_date.group(:account_id).select(:account_id) if group_by_account
    by_date.order('txns.date')
  end

  def self.by_day(metric, group_by_account: false)
    handle_error(metric)
    by_date(metric, group_by_account: group_by_account).each_with_object({}) do |entry, amounts|
      if group_by_account
        amounts[entry.account_id] ||= {}
        amounts[entry.account_id][entry.date] = entry.total_amount
      else
        amounts[entry.date] = entry.total_amount
      end
    end
  end

  def self.net(type)
    metric = "net_#{type}".to_sym
    handle_error(metric)
    sum(QUERIES[metric])
  end

  private

  def self.handle_error(metric)
    raise ArgumentError.new("Metric must be one of #{QUERIES.keys}") unless QUERIES[metric].present?
  end

  def cache_balances
    Entry::CacheBalances.new(self).call
  end
end
