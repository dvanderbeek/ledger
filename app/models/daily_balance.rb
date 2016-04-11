class DailyBalance
  attr_reader :accounts, :date_range, :for_product

  def initialize(accounts, date_range:, for_product: nil)
    @accounts = accounts
    @date_range = date_range
    @for_product = for_product
  end

  def calculate
    previous_balance = starting_balance.to_f
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
                                 .by_day(:net_credits, group_by_account: true)
  end

  def starting_balance
    @starting_balance ||= accounts.map do |account|
      if net_credits_by_day[account.id]
        net_credits_by_day[account.id].map do |date, amount|
          date < date_range.first ? amount * account.credit_multiplier : 0
        end.reduce(0, :+)
      else
        0
      end
    end.reduce(0, :+)
  end
end
