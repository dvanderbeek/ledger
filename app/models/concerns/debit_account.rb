module DebitAccount
  def balance(as_of: Date.current, product_uuid: nil)
    (
      debits.as_of(as_of).for_product(product_uuid).map(&:amount_cents).reduce(0, :+) -
      credits.as_of(as_of).for_product(product_uuid).map(&:amount_cents).reduce(0, :+)
    ).to_f
  end
end
