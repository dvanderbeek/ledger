class Account < ActiveRecord::Base
  has_ancestry cache_depth: true

  has_many :entries
  has_many :debits, inverse_of: :account, class_name: Entry::Debit
  has_many :credits, inverse_of: :account, class_name: Entry::Credit
  has_many :product_balances

  validates :name, presence: true, uniqueness: true

  before_destroy :check_for_entries

  def self.method_missing(method, *args, &block)
    find_by(name: method)
  end

  def self.balance(*names, as_of: Date.current, for_product: nil, include_subtree: nil)
    include_subtree ||= names.flatten.count == 1
    self.daily_balance(*names, date_range: as_of..as_of, for_product: for_product, include_subtree: include_subtree)[as_of]
  end

  def self.balance_for_new_record(*names, as_of: Date.current, for_product: nil)
    where(name: names).map { |account| account.balance_for_new_record(as_of: as_of, for_product: for_product) }.reduce(:+)
  end

  def self.daily_balance(*names, date_range: 1.month.ago.to_date..Date.current.to_date, for_product: nil, include_subtree: nil)
    include_subtree ||= names.flatten.count == 1
    DailyBalance.new(
      Account.where(name: include_subtree ? get_subtree(names.flatten) : names.flatten),
      date_range: date_range,
      for_product: for_product
    ).calculate
  end

  def balance(as_of: Date.current, for_product: nil)
    Entry.where(account: self.subtree)
      .as_of(as_of)
      .for_product(for_product)
      .net(credit_account? ? :credits : :debits)
  end

  # TODO: make balance include subtree
  def balance_for_new_record(as_of: Date.current, for_product: nil)
    increasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
      decreasing_entries.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
  end

  def daily_balance(date_range:, for_product: nil)
    DailyBalance.new(self.subtree, date_range: date_range, for_product: for_product).calculate
  end

  private

  def self.get_subtree(names)
    names.map { |name| Account.find_by(name: name).subtree.pluck(:name) }.flatten.uniq
  end

  def check_for_entries
    if entries.any? || has_children?
      errors.add(:base, 'can not be modified')
      false
    end
  end
end
