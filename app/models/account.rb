class Account < ActiveRecord::Base
  has_many :entries
  has_many :debits, inverse_of: :account, class_name: Entry::Debit
  has_many :credits, inverse_of: :account, class_name: Entry::Credit

  validates :name, presence: true, uniqueness: true

  def self.method_missing(method, *args, &block)
    find_by(name: method)
  end

  def self.balance(names, as_of: Date.current, for_product: nil)
    where(name: names).map { |account| account.balance(as_of: as_of, for_product: for_product) }.reduce(:+)
  end

  def self.daily_balance(names, date_range:, for_product: nil)
    DailyBalance.new(names, date_range: date_range, for_product: for_product).calculate
  end

  def balance(as_of: Date.current, for_product: nil)
    entries
      .as_of(as_of)
      .for_product(for_product)
      .net(credit_account? ? :credits : :debits)
  end

  def balance_for_new_record(as_of: Date.current, for_product: nil)
    increasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
      decreasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
  end

  def daily_balance(date_range:, for_product: nil)
    DailyBalance.new(self, date_range: date_range, for_product: for_product).calculate
  end
end
