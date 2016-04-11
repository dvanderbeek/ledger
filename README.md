Ledger
======

Getting Started
---------------

You will need to install Ruby 2.1.2 to run this app. With RVM, run:

    $ rvm install 2.1.2
    $ rvm use 2.1.2

This repository comes equipped with a self-setup script:

    $ ./bin/setup

After setting up, you can run the application using [foreman]:

    $ foreman start

[foreman]: http://ddollar.github.io/foreman/

Basic Usage
-----------

Create `Txns` with equal `Debits` and `Credits`. `Txn` has its name because "Transaction" is a reserved word.

```ruby
Txn.create(
  name: "Initial Funding",
  date: Date.new(2014, 12, 1),
  debits: { cash: 100000000 },
  credits: { equity: 100000000 },
)

Txn.create(
  name: "Issue Loan",
  product_uuid: 1,
  date: Date.new(2015, 1, 1),
  debits: { principal: 200000 },
  credits: { cash: 200000 },
)

(Date.new(2015, 1, 2)..Date.new(2015, 2, 15)).each do |date|
  Txn.create(
    name: "Book Interest",
    product_uuid: 1,
    date: date,
    debits: { accrued_interest: 50 },
    credits: { interest_income: 50 },
  )
end

payment_date = Date.new(2015, 2, 1)
payment = 2000.to_d
interest = Account.accrued_interest.balance(for_product: 1, as_of: payment_date)
principal = payment - interest

Txn.create(
  name: "Book Installment",
  product_uuid: 1,
  date: payment_date,
  debits: {
    interest_receivable: interest,
    principal_receivable: principal,
  },
  credits: {
    accrued_interest: interest,
    principal: principal,
  },
)

Txn.create(
  name: "Initiate Payment",
  product_uuid: 1,
  date: payment_date,
  debits: {
    pending_interest: interest,
    pending_principal: principal,
  },
  credits: {
    interest_receivable: interest,
    principal_receivable: principal,
  }
)

Txn.create(
  name: "Process Payment",
  product_uuid: 1,
  date: payment_date + 2.days,
  debits: { cash: payment },
  credits: {
    pending_interest: interest,
    pending_principal: principal,
  },
)

account = Account.interest_income
account.balance
account.balance(for_product: 1)
account.balance(for_product: 1, as_of: Date.yesterday)
account.debits.for_product(1).as_of(1.year.ago)
account.credits.for_product(1).as_of(1.year.ago)
account.credits.for_product(1).as_of(1.year.ago).sum(:amount_cents)

# Payments processed by date
Account.cash.debits.for_product(1).by_day(:amount_cents)
# Daily balance of accrued interest
Account.accrued_interest.daily_balance(date_range: Date.new(2015, 1, 1)..Date.new(2015, 2, 5), for_product: 1)
# Total balance for multiple accounts
Account.balance(:interest_receivable, :principal_receivable, for_product: 1)
Account.balance(:pending_payments, for_product: 2, as_of: Date.new(2015, 5, 1))
# Total daily balance for multiple accounts
Account.daily_balance(:principal, :principal_receivable, date_range: Date.new(2015,4,1)..Date.new(2015,5,5), for_product: 2)
Account.daily_balance(:principal, :principal_receivable, date_range: Date.new(2014,12,1)..Date.new(2015,1,5), for_product: 4)

# Accounts that are late as of a specific date
Account.accounts_receivable.product_balances.by_product.positive.as_of(Date.new(2015, 2, 1))
# As of today
Account.accounts_receivable.product_balances.by_product.positive
# Late or early
Account.accounts_receivable.product_balances.by_product.as_of(Date.new(2015, 2, 1))

# Total Assets
Account.balance(Account::Asset.pluck(:name))
```

To Do
-----

[ ] Need a way to get the sum of product balances for multiple accounts by product_uuid at a point in time

[ ] 500k 60 month loans would create ~1.8B Book Interest rows - probably need to shard the database

Client
------

* Set up necessary accounts
* Add Event interactors with logic for creating a Txn:

  `BookIntsallment.new().process(product_uuid: 1, amount_cents: 2000, interest_cents: 1000)`

* Txn should store event_id so adjustments can be grouped with original Txn.

Guidelines
----------

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
