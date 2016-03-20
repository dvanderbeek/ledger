module CreditAccount
  def balance(as_of: Date.current, product_uuid: nil)
    (
      credits.as_of(as_of).for_product(product_uuid).map(&:amount_cents).reduce(:+) -
      debits.as_of(as_of).for_product(product_uuid).map(&:amount_cents).reduce(:+)
    ).to_f
  end
end
