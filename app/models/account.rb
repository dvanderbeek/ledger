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

  def balance(as_of: Date.current, for_product: nil)
    increasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
    decreasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
  end

  def persisted_balance(as_of: Date.current, for_product: nil)
    entries.as_of(as_of).for_product(for_product).net_credits * credit_multiplier
  end

  def daily_balance(date_range:, for_product: nil)
    net_credits_by_day = entries.net_credits_by_day(as_of: date_range.last, for_product: for_product)
    starting_balance = net_credits_by_day.map { |k, v| k < date_range.first ? v : 0 }.reduce(:+)
    date_range.each_with_object({}) do |date, balances|
      balances[date] = (
        starting_balance + net_credits_by_day.fetch(date, 0) * credit_multiplier
      ).to_f
      starting_balance = balances[date]
    end
  end
end
