class Entry
  class Credit < ::Entry
    def balance_change_cents
      account.credit_account? ? amount_cents : -amount_cents
    end
  end
end
