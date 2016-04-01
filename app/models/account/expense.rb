class Account
  class Expense < ::Account
    include DebitAccount
  end
end
