module DebitAccount
  def increasing_entries
    debits
  end

  def decreasing_entries
    credits
  end

  def credit_multiplier
    -1
  end

  def balance_method
    :net_debits
  end
end
