module Accounts
  class Liability < ::Account
    include CreditAccount
  end
end
