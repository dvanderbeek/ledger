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
interest = Account.named(:accrued_interest).balance(for_product: 1, as_of: payment_date)
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
  debits: { pending_payments: payment },
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
  credits: { pending_payments: payment },
)

account = Account.named(:interest_income)
account.balance
account.balance(for_product: 1)
account.balance(for_product: 1, as_of: Date.yesterday)
account.debits.for_product(1).as_of(1.year.ago)
account.credits.for_product(1).as_of(1.year.ago)
account.credits.for_product(1).as_of(1.year.ago).sum(:amount_cents)

Account.accrued_interest.daily_balance(date_range: Date.new(2015, 1, 1)..Date.new(2015, 2, 5), for_product: 1)
```

To Do
-----

[ ] Store date and product uuid on Txn also for querying

[ ] Change Entry.date to timestamp?

[ ] Convert to Sinatra Service

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
