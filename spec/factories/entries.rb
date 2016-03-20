FactoryGirl.define do
  factory :entry do
    transaction nil
    account nil
    debit_cents "9.99"
    credit_cents "9.99"
  end
end
