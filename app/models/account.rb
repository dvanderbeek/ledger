class Account < ActiveRecord::Base
  has_many :entries
  has_many :debits, class_name: Entries::Debit
  has_many :credits, class_name: Entries::Credit

  validates :name, presence: true, uniqueness: true

  def self.named(name)
    find_by(name: name)
  end

  def self.method_missing(method, *args, &block)
    named(method)
  end

  def daily_balance(date_range:, for_product: nil)
    credits_by_day = credits.amounts_by_day(start_date: date_range.first, end_date: date_range.last, for_product: for_product)
    debits_by_day = debits.amounts_by_day(start_date: date_range.first, end_date: date_range.last, for_product: for_product)
    starting_balance = persisted_balance(as_of: date_range.first - 1.day, for_product: for_product)
    date_range.each_with_object({}) do |date, balances|
      balances[date] = (starting_balance + balance_change(date, credits_by_day, debits_by_day)).to_f
      starting_balance = balances[date]
    end
  end
end
