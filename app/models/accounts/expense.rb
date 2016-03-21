module Accounts
  class Expense < ::Account
    include DebitAccount
  end
end
