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
    names = [names] unless names.is_a?(Array)
    names.map { |name| named(name).balance(as_of: as_of, for_product: for_product) }.reduce(:+)
  end

  def self.persisted_balance(names, as_of: Date.current, for_product: nil)
    names = [names] unless names.is_a?(Array)
    names.map { |name| named(name).persisted_balance(as_of: as_of, for_product: for_product) }.reduce(:+)
  end

  def self.daily_balance(ids, date_range:, for_product: nil)
    net_credits_by_day = Entry.where(account_id: ids).as_of(date_range.last).for_product(for_product).net_credits_by_day
    results = date_range.each_with_object({}) { |date, balances| balances[date] = 0 }
    Account.where(id: ids).each do |account|
      starting_balance = net_credits_by_day[account.id].map { |k, v| k < date_range.first ? v * account.credit_multiplier : 0 }.reduce(:+).to_f
      results.each do |date, balance|
        results[date] += starting_balance
        results[date] += net_credits_by_day[account.id].fetch(date, 0).to_f * account.credit_multiplier
        starting_balance = results[date]
      end
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
    net_credits_by_day = entries.as_of(date_range.last).for_product(for_product).net_credits_by_day[id]
    starting_balance = net_credits_by_day.map { |k, v| k < date_range.first ? v * credit_multiplier : 0 }.reduce(:+).to_f
    date_range.each_with_object({}) do |date, balances|
      balances[date] = starting_balance + net_credits_by_day.fetch(date, 0).to_f * credit_multiplier
      starting_balance = balances[date]
    end
  end
end
