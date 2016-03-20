FactoryGirl.define do
  factory :entry do
    txn
    account
    amount_cents 1000
  end
end
