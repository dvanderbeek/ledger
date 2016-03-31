class DailyBalance
  attr_reader :accounts, :date_range, :for_product

  def initialize(account_names, date_range:, for_product: nil)
    @accounts = account_names.is_a?(Account) ? [account_names] : Account.where(name: account_names)
    @date_range = date_range
    @for_product = for_product
  end

  def calculate
    previous_balance = starting_balance
    date_range.each_with_object({}) do |date, balances|
      balances[date] = previous_balance
      accounts.each do |account|
        balances[date] += (net_credits_by_day[account.id] || {}).fetch(date, 0).to_f * account.credit_multiplier
      end
      previous_balance = balances[date]
    end
  end

  private

  def net_credits_by_day
    @net_credits_by_day ||= Entry.where(account: accounts)
                                 .as_of(date_range.last)
                                 .for_product(for_product)
                                 .net_credits_by_day
  end

  def starting_balance
    @starting_balance ||= accounts.map do |account|
      net_credits_by_day[account.id].map do |date, amount|
        date < date_range.first ? amount * account.credit_multiplier : 0
      end.reduce(0, :+)
    end.reduce(0, :+).to_f
  end
end
