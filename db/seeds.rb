ar = Account::Asset.create(name: :accounts_receivable)

Account::Asset.create([
  { name: :accrued_interest },
  { name: :principal_receivable, parent: ar },
  { name: :interest_receivable, parent: ar },
  { name: :pending_payments },
  { name: :cash },
  { name: :principal },
])

Account::Revenue.create([
  { name: :interest_income },
])

Account::Equity.create([
  { name: :equity },
])

event = Event.create(name: :issue_loan)
action = Action::CreateTxn.create(event: event, name: :create_txn, credit_account: Account.cash, debit_account: Account.principal)

event = Event.create(name: :book_interest)
action = Action::CreateTxn.create(event: event, name: :create_txn, credit_account: Account.interest_income, debit_account: Account.accrued_interest)

event = Event.create(name: :book_installment)
action = Action::CreateWaterfallTxn.create(event: event, name: :create_txn)
action.waterfalls.create(credit_account: Account.accrued_interest, debit_account: Account.interest_receivable, order: 0, from_account: Account.accrued_interest)
action.waterfalls.create(credit_account: Account.principal, debit_account: Account.principal_receivable, order: 1, from_account: Account.principal)

event = Event.create(name: :initiate_payment)
action = Action::CreateWaterfallTxn.create(event: event, name: :create_txn)
action.waterfalls.create(credit_account: Account.accrued_interest, debit_account: Account.pending_payments, order: 0, from_account: Account.accrued_interest)
action.waterfalls.create(credit_account: Account.interest_receivable, debit_account: Account.pending_payments, order: 1, from_account: Account.interest_receivable)
action.waterfalls.create(credit_account: Account.principal_receivable, debit_account: Account.pending_payments, order: 2, from_account: Account.principal_receivable)

event = Event.create(name: :process_payment)
action = Action::CreateWaterfallTxn.create(event: event, name: :create_txn)
action.waterfalls.create(credit_account: Account.pending_payments, debit_account: Account.cash, order: 0, from_account: Account.pending_payments)
action.waterfalls.create(credit_account: Account.principal_receivable, debit_account: Account.cash, order: 1, from_account: Account.principal_receivable)

Txn.create(
  name: "Initial Funding",
  date: Date.new(2014, 1, 1),
  debits: { cash: 100000000 },
  credits: { equity: 100000000 },
)

###################################################
# EXAMPLE LOAN 1 - On time payment, then late payment (with interest)
###################################################
puts "Example Loan 1"

Event.named(:issue_loan).trigger(amount_cents: 200000, date: Date.new(2015, 1, 1), product_uuid: 1)

(Date.new(2015, 1, 2)..Date.new(2015, 2, 1)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 50, date: date, product_uuid: 1)
end

Event.named(:book_installment).trigger(amount_cents: 2000, date: Date.new(2015, 2, 1), product_uuid: 1)
Event.named(:initiate_payment).trigger(amount_cents: 2000, date: Date.new(2015, 2, 1), product_uuid: 1)
Event.named(:process_payment).trigger(amount_cents: 2000, date: Date.new(2015, 2, 3), product_uuid: 1)

(Date.new(2015, 2, 2)..Date.new(2015, 3, 1)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 40, date: date, product_uuid: 1)
end

Event.named(:book_installment).trigger(amount_cents: 2000, date: Date.new(2015, 3, 1), product_uuid: 1)

(Date.new(2015, 3, 2)..Date.new(2015, 3, 5)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 50, date: date, product_uuid: 1)
end

Event.named(:initiate_payment).trigger(amount_cents: 2000, date: Date.new(2015, 3, 5), product_uuid: 1)
Event.named(:process_payment).trigger(amount_cents: 2000, date: Date.new(2015, 3, 5), product_uuid: 1)

(Date.new(2015, 3, 6)..Date.new(2015, 3, 31)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 40, date: date, product_uuid: 1)
end

###################################################
# EXAMPLE LOAN 2: Pmt Plan, apply to future
###################################################
puts "Example Loan 2"
Event.named(:issue_loan).trigger(amount_cents: 40000, date: Date.new(2014, 12, 1), product_uuid: 2)

t = Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 1, 1),
  debits: { principal_receivable: 10000 },
  credits: { principal: 10000 },
)

t.reversals.create(name: "Start Payment Plan")

# Early Payment
Event.named(:process_payment).trigger(amount_cents: 15000, date: Date.new(2015, 1, 15), product_uuid: 2)
Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 2, 1), product_uuid: 2)
Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 3, 1), product_uuid: 2)
Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 4, 1), product_uuid: 2)

t = Txn.create(
  name: "Initiate Payment",
  product_uuid: 2,
  date: Date.new(2015, 4, 1),
  debits: { pending_payments: 7500 },
  credits: { principal_receivable: 7500 },
)

# If payment is processed before it returns, we'd
#   also need to reverse the process payment Txn.
t.reversals.create(name: "Payment Return")

Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 5, 1), product_uuid: 2)
Event.named(:initiate_payment).trigger(amount_cents: 7500, date: Date.new(2015, 5, 1), product_uuid: 2)
Event.named(:process_payment).trigger(amount_cents: 7500, date: Date.new(2015, 5, 3), product_uuid: 2)

###################################################
# EXAMPLE LOAN 3: Pmt Plan, DO NOT apply to future, miss payments
###################################################
puts "Example Loan 3"
Event.named(:issue_loan).trigger(amount_cents: 40000, date: Date.new(2014, 12, 1), product_uuid: 3)

t = Txn.create(
  name: "Book Installment",
  product_uuid: 3,
  date: Date.new(2015, 1, 1),
  debits: { principal_receivable: 10000 },
  credits: { principal: 10000 },
)

t.reversals.create(name: "Start Payment Plan")

Event.named(:process_payment).trigger(amount_cents: 15000, date: Date.new(2015, 1, 15), product_uuid: 3)
Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 2, 1), product_uuid: 3)
Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 3, 1), product_uuid: 3)
Event.named(:book_installment).trigger(amount_cents: 7500, date: Date.new(2015, 4, 1), product_uuid: 3)
Event.named(:book_installment).trigger(amount_cents: 2500, date: Date.new(2015, 5, 1), product_uuid: 3)

###################################################
# EXAMPLE LOAN 4: Pmt 1, Pmt 2, Pmt 1 Returns
###################################################
puts "Example Loan 4"
Event.named(:issue_loan).trigger(amount_cents: 200000, date: Date.new(2014, 12, 1), product_uuid: 4)

(Date.new(2014, 12, 2)..Date.new(2015, 1, 1)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 50, date: date, product_uuid: 4)
end

inst_1 = Txn.create(
  name: "Book Installment",
  product_uuid: 4,
  date: Date.new(2015, 1, 1),
  debits: {
    interest_receivable: 1550,
    principal_receivable: 2000 - 1550,
  },
  credits: {
    accrued_interest: 1550,
    principal: 2000 - 1550,
  },
)

initiate_pmt_1 = Txn.create(
  name: "Initiate Payment",
  product_uuid: 4,
  date: Date.new(2015, 1, 1),
  debits: {
    pending_payments: 2000,
  },
  credits: {
    accrued_interest: 0,
    interest_receivable: 1550,
    principal_receivable: 2000 - 1550,
  }
)

# Book less interest now that principal is in "pending" account
(Date.new(2015, 1, 2)..Date.new(2015, 1, 3)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 40, date: date, product_uuid: 4)
end

process_pmt_1 = Txn.create(
  name: "Process Payment",
  product_uuid: 4,
  date: Date.new(2015, 1, 3),
  debits: { cash: 2000 },
  credits: {
    pending_payments: 2000,
  },
)

(Date.new(2015, 1, 4)..Date.new(2015, 1, 5)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 40, date: date, product_uuid: 4)
end

initiate_pmt_2 = Txn.create(
  name: "Initiate Payment",
  product_uuid: 4,
  date: Date.new(2015, 1, 5),
  debits: {
    pending_payments: 2000,
  },
  credits: {
    accrued_interest: 160,
    principal_receivable: 2000 - 160,
  }
)

process_pmt_2 = Txn.create(
  name: "Process Payment",
  product_uuid: 4,
  date: Date.new(2015, 1, 5),
  debits: { cash: 2000 },
  credits: {
    pending_payments: 2000,
  },
)

# Payment 1 Returns
initiate_pmt_1.reversals.create(name: "Payment Return")
process_pmt_1.reversals.create(name: "Payment Return")

# Adjust interest booked for higher principal balance
(Date.new(2015, 1, 2)..Date.new(2015, 1, 5)).each do |date|
  Event.named(:book_interest).trigger(amount_cents: 10, date: date, product_uuid: 4)
end

# Adjust payment 2 breakdown
# interest_receivable = 1550 (interest_receivable balance as of 1/5 = returned payment interest amount)
# additional accrued_interest = 40 (accrued_interest balance as of 1/5 = total additional interest booked)
# total_interest_adjustment = 1550 + 40 = 1590
# principal_adjustment = (2000 - 160) - (2000 - 1750) = total_interest_adjustment = 1590
# => interest is increasing, so the related credits / debits are the same as the original
# => principal portion is decreasing, so the related credits / debits are opposite of the original
initiate_pmt_2.adjustments.create(
  name: "Initiate Payment Adjustment",
  debits: {
    principal_receivable: 1590,
  },
  credits: {
    accrued_interest: 40,
    interest_receivable: 1550,
  }
)
