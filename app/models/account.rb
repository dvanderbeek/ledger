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
    (
      increasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
      decreasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
    ).to_f
  end

  def persisted_balance(as_of: Date.current, for_product: nil)
    (
      increasing_entries.as_of(as_of).for_product(for_product).sum(:amount_cents) -
      decreasing_entries.as_of(as_of).for_product(for_product).sum(:amount_cents)
    ).to_f
  end

  def daily_balance(date_range:, for_product: nil)
    increasing_entries_by_day = increasing_entries.amounts_by_day(start_date: date_range.first, end_date: date_range.last, for_product: for_product)
    decreasing_entries_by_day = decreasing_entries.amounts_by_day(start_date: date_range.first, end_date: date_range.last, for_product: for_product)
    starting_balance = persisted_balance(as_of: date_range.first - 1.day, for_product: for_product)
    date_range.each_with_object({}) do |date, balances|
      balances[date] = (
        starting_balance + 
        increasing_entries_by_day.fetch(date, 0) -
        decreasing_entries_by_day.fetch(date, 0)
      ).to_f
      starting_balance = balances[date]
    end
  end
end
