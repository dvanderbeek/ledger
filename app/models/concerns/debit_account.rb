module DebitAccount
  def balance(as_of: Date.current, product_uuid: nil)
    (
      debits.as_of(as_of).for_product(product_uuid).sum(:amount_cents) -
      credits.as_of(as_of).for_product(product_uuid).sum(:amount_cents)
    ).to_f
  end
end
