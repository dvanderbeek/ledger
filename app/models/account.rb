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

  def self.balance(names, as_of: Date.current, for_product: nil)
    where(name: names).map { |account| account.balance(as_of: as_of, for_product: for_product) }.reduce(:+)
  end

  def self.persisted_balance(names, as_of: Date.current, for_product: nil)
    where(name: names).map { |account| account.persisted_balance(as_of: as_of, for_product: for_product) }.reduce(:+)
  end

  def self.daily_balance(names, date_range:, for_product: nil)
    DailyBalance.new(names, date_range: date_range, for_product: for_product).calculate
  end

  def balance(as_of: Date.current, for_product: nil)
    increasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
    decreasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
  end

  def persisted_balance(as_of: Date.current, for_product: nil)
    entries.as_of(as_of).for_product(for_product).public_send(balance_method)
  end

  def daily_balance(date_range:, for_product: nil)
    DailyBalance.new(self, date_range: date_range, for_product: for_product).calculate
  end
end
