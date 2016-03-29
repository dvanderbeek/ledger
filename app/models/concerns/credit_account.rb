module CreditAccount
  def balance(as_of: Date.current, for_product: nil)
    (
      credits.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+) -
      debits.as_of(as_of).for_product(for_product).map(&:amount_cents).reduce(0, :+)
    ).to_f
  end

  def persisted_balance(as_of: Date.current, for_product: nil)
    (
      credits.as_of(as_of).for_product(for_product).sum(:amount_cents) -
      debits.as_of(as_of).for_product(for_product).sum(:amount_cents)
    ).to_f
  end
end
