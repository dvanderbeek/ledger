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

  # TODO: Make a new class to do this calculation
  def self.daily_balance(names, date_range:, for_product: nil)
    accounts = names.is_a?(Account) ? [names] : Account.where(name: names)
    net_credits_by_day = Entry.where(account: accounts).as_of(date_range.last).for_product(for_product).net_credits_by_day

    results = date_range.each_with_object({}) { |date, balances| balances[date] = 0 }
    starting_balance = accounts.map do |account|
      net_credits_by_day[account.id].map { |k, v| k < date_range.first ? v * account.credit_multiplier : 0 }.reduce(:+)
    end.reduce(:+).to_f

    results.each do |date, balance|
      results[date] = starting_balance
      accounts.each do |account|
        results[date] += net_credits_by_day[account.id].fetch(date, 0).to_f * account.credit_multiplier
      end
      starting_balance = results[date]
    end

    results
  end

  def balance(as_of: Date.current, for_product: nil)
    increasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
    decreasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
  end

  def persisted_balance(as_of: Date.current, for_product: nil)
    entries.as_of(as_of).for_product(for_product).net_credits * credit_multiplier
  end

  def daily_balance(date_range:, for_product: nil)
    Account.daily_balance(self, date_range: date_range, for_product: for_product)
  end
end
