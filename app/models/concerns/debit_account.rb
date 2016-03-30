module DebitAccount
  def balance(as_of: Date.current, for_product: nil)
    (
      debits.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
      credits.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
    ).to_f
  end

  def persisted_balance(as_of: Date.current, for_product: nil)
    (
      debits.as_of(as_of).for_product(for_product).sum(:amount_cents) -
      credits.as_of(as_of).for_product(for_product).sum(:amount_cents)
    ).to_f
  end

  def balance_change(date, credits_by_day, debits_by_day)
    (debits_by_day[date] || 0) - (credits_by_day[date] || 0)
  end
end
