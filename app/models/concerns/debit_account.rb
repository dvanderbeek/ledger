module DebitAccount
  def balance(as_of: Time.current, product_uuid: nil)
    (
      debits.as_of(as_of).for_product(product_uuid).sum(:amount_cents) -
      credits.as_of(as_of).for_product(product_uuid).sum(:amount_cents)
    ).to_f
  end
end
