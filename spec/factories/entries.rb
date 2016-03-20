FactoryGirl.define do
  factory :entry do
    txn
    account
    amount_cents 1000
    product_uuid "asdf123"
    date { Date.current }
  end
end
