Accountant
==========

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
  date: 40.days.ago,
  debits: { cash: 100000000 },
  credits: { equity: 100000000 },
)

Txn.create(
  name: "Issue Loan",
  product_uuid: 1,
  date: 35.days.ago,
  debits: { loans: 200000 },
  credits: { cash: 200000 },
)

# Every day
(0..34).each do |n|
  Txn.create(
    name: "Book Interest",
    product_uuid: 1,
    date: Date.current - n.days,
    debits: { accrued_interest: 50 },
    credits: { interest_income: 50 },
  )
end

int = Account.named(:accrued_interest).balance(product_uuid: 1, as_of: 4.days.ago)
Txn.create(
  name: "Installment",
  product_uuid: 1,
  date: 4.days.ago,
  debits: { accounts_receivable: 2000 },
  credits: {
    accrued_interest: int,
    loans: 2000 - int,
  },
)

Txn.create(
  name: "Process Payment",
  product_uuid: 1,
  date: 2.days.ago,
  debits: { cash: 2000 },
  credits: { accounts_receivable: 2000 },
)

account = Account.named(:interest_income)
account.balance
account.balance(product_uuid: 1)
account.balance(product_uuid: 1, as_of: Date.yesterday)
account.debits.for_product(1).as_of(1.year.ago)
account.credits.for_product(1).as_of(1.year.ago)
account.credits.for_product(1).as_of(1.year.ago).sum(:amount_cents)
```

To Do
-----

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
