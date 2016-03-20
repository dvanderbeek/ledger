debits_hash = { accounts_receivable: 1000 }
credits_hash = { interest_income: 1000 }

FactoryGirl.define do
  factory :txn do
    name "MyString"
    product_uuid 1
    debits debits_hash
    credits credits_hash
  end
end
