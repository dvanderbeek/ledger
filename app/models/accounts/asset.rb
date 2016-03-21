module Accounts
  class Asset < ::Account
    include DebitAccount
  end
end
