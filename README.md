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
    debits: { interest_receivable: 50 },
    credits: { interest_income: 50 },
  )
end

int = Account.named(:interest_receivable).balance(product_uuid: 1, as_of: 4.days.ago)
Txn.create(
  name: "Installment",
  product_uuid: 1,
  date: 4.days.ago,
  debits: { accounts_receivable: 2000 },
  credits: {
    interest_receivable: int,
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

Account.named(:interest_income).balance(product_uuid: 1) # Interest income from Loan 1
Account.named(:interest_income).balance # Total interest income
Account.named(:interest_income).balance(as_of: Date.yesterday) # Total interest income as of a point in time

Account.named(:interest_income).credits.for_product(1).as_of(1.year.ago) # All credits to the interest_income account for Loan 1 as of a year ago
Account.named(:interest_income).credits.for_product(1).as_of(1.year.ago).sum(:amount_cents) # Total amount of those credits
```

To Do
-----

[ ] Change Entry.date to timestamp

[ ] Convert to Sinatra Service

Client
------

* Set up necessary accounts
* Add interactors with Debit and Credit logic for Transactions:

  `BookIntsallment.new().process(product_uuid: 1, amount_cents: 2000, interest_cents: 1000)`

Guidelines
----------

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
