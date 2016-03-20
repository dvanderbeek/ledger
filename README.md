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

```ruby
Txn.create(name: "Installment", product_uuid: 1, debits: { accounts_receivable: 2000 }, credits: { interest_income: 1000, loans: 1000 })

Txn.create(name: "Process Payment", product_uuid: 1, debits: { cash: 2000 }, credits: { accounts_receivable: 2000 })

Account.named(:interest_income).balance(product_uuid: 1) # Interest income from Loan 1
Account.named(:interest_income).balance # Total interest income
```

To Do
-----

[] Convert to Sinatra Service
[] Add tests

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
