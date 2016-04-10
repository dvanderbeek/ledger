class Entry
  class Debit < ::Entry
    def balance_change_cents
      account.debit_account? ? amount_cents : -amount_cents
    end
  end
end
