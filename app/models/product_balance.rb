class ProductBalance < ActiveRecord::Base
  belongs_to :account

  scope :as_of, -> (date) { where('date <= ?', date) }
  scope :by_product, -> { select("DISTINCT ON (product_uuid) *").order("product_uuid, date desc") }
  scope :for_accounts, -> (*names) { joins(:account).merge(Account.where(name: names)) }
  scope :for_product, -> (uuid) { where(product_uuid: uuid) }
  scope :positive, -> { where('amount_cents > ?', 0) }

  def self.by_account
    all.each_with_object({}) do |product_balance, hsh|
      hsh[product_balance.account_id] = product_balance.amount_cents
    end
  end

  def self.time_series(date_range = 1.month.ago.to_date..Date.current.to_date)
    by_date = by_date(date_range)
    date_range.each_with_object({}) do |date, hash|
      hash[date] = by_date[date] || hash[date - 1] || starting_balance(as_of: date_range.first)
    end
  end

  def self.by_date(date_range)
    where(date: date_range).each_with_object({}) do |balance, hash|
      hash[balance.date] = balance.amount_cents
    end
  end

  def self.starting_balance(as_of: Date.current)
    previous(as_of: as_of).amount_cents
  end

  def self.previous(as_of: Date.current)
    where('date < ?', as_of).order(date: :asc).last || OpenStruct.new(amount_cents: 0)
  end
end
