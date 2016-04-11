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
Txn.create(
  name: "Issue Loan",
  product_uuid: 1,
  date: Date.new(2015, 1, 1),
  debits: { principal: 200000 },
  credits: { cash: 200000 },
)

(Date.new(2015, 1, 2)..Date.new(2015, 2, 1)).each do |date|
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
    pending_payments: payment,
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
  credits: { pending_payments: payment },
)

(Date.new(2015, 2, 2)..Date.new(2015, 3, 1)).each do |date|
  Txn.create(
    name: "Book Interest",
    product_uuid: 1,
    date: date,
    debits: { accrued_interest: 40 },
    credits: { interest_income: 40 },
  )
end

installment_date = Date.new(2015, 3, 1)
late_payment_date = Date.new(2015, 3, 5)
payment = 2000
interest = Account.balance([:accrued_interest, :interest_receivable], for_product: 1, as_of: installment_date) # 1120
principal = payment - interest # 880

Txn.create(
  name: "Book Installment",
  product_uuid: 1,
  date: installment_date,
  debits: {
    interest_receivable: interest,
    principal_receivable: principal,
  },
  credits: {
    accrued_interest: interest,
    principal: principal,
  },
)

(Date.new(2015, 3, 2)..Date.new(2015, 3, 5)).each do |date|
  Txn.create(
    name: "Book Interest",
    product_uuid: 1,
    date: date,
    debits: { accrued_interest: 50 },
    credits: { interest_income: 50 },
  )
end

accrued_interest = Account.balance(:accrued_interest, for_product: 1, as_of: late_payment_date) # 200
interest_receivable = Account.balance(:interest_receivable, for_product: 1, as_of: late_payment_date) # 1120
total_interest = Account.balance([:accrued_interest, :interest_receivable], for_product: 1, as_of: late_payment_date) # 1320
principal = payment - total_interest # 680

Txn.create(
  name: "Initiate Payment",
  product_uuid: 1,
  date: late_payment_date,
  debits: {
    pending_payments: payment,
  },
  credits: {
    accrued_interest: accrued_interest,
    interest_receivable: interest_receivable,
    principal_receivable: principal,
  }
)

Txn.create(
  name: "Process Payment",
  product_uuid: 1,
  date: late_payment_date + 2.days,
  debits: { cash: payment },
  credits: {
    pending_payments: payment,
  },
)

###################################################
# EXAMPLE LOAN 2: Pmt Plan, apply to future
###################################################
puts "Example Loan 2"
Txn.create(
  name: "Issue Loan",
  product_uuid: 2,
  date: Date.new(2014, 12, 1),
  debits: { principal: 40000 },
  credits: { cash: 40000 },
)

t = Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 1, 1),
  debits: { principal_receivable: 10000 },
  credits: { principal: 10000 },
)

t.reversals.create(name: "Start Payment Plan")

# Early Payment
Txn.create(
  name: "Process Payment",
  product_uuid: 2,
  date: Date.new(2015, 1, 15),
  debits: { cash: 15000 },
  credits: { principal_receivable: 15000 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 2, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 3, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 4, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

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

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 5, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Initiate Payment",
  product_uuid: 2,
  date: Date.new(2015, 5, 1),
  debits: { pending_payments: 7500 },
  credits: { principal_receivable: 7500 },
)

Txn.create(
  name: "Process Payment",
  product_uuid: 2,
  date: Date.new(2015, 5, 3),
  debits: { cash: 7500 },
  credits: { pending_payments: 7500 },
)

###################################################
# EXAMPLE LOAN 3: Pmt Plan, DO NOT apply to future, miss payments
###################################################
puts "Example Loan 3"
Txn.create(
  name: "Issue Loan",
  product_uuid: 3,
  date: Date.new(2014, 12, 1),
  debits: { principal: 40000 },
  credits: { cash: 40000 },
)

t = Txn.create(
  name: "Book Installment",
  product_uuid: 3,
  date: Date.new(2015, 1, 1),
  debits: { principal_receivable: 10000 },
  credits: { principal: 10000 },
)

t.reversals.create(name: "Start Payment Plan")

Txn.create(
  name: "Process Payment",
  product_uuid: 3,
  date: Date.new(2015, 1, 15),
  debits: { cash: 15000 },
  credits: { principal_receivable: 15000 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 3,
  date: Date.new(2015, 2, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 3,
  date: Date.new(2015, 3, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 3,
  date: Date.new(2015, 4, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 3,
  date: Date.new(2015, 5, 1),
  debits: { principal_receivable: 2500 },
  credits: { principal: 2500 },
)

###################################################
# EXAMPLE LOAN 4: Pmt 1, Pmt 2, Pmt 1 Returns
###################################################
puts "Example Loan 4"
Txn.create(
  name: "Issue Loan",
  product_uuid: 4,
  date: Date.new(2014, 12, 1),
  debits: { principal: 200000 },
  credits: { cash: 200000 },
)

(Date.new(2014, 12, 2)..Date.new(2015, 1, 1)).each do |date|
  Txn.create(
    name: "Book Interest",
    product_uuid: 4,
    date: date,
    debits: { accrued_interest: 50 },
    credits: { interest_income: 50 },
  )
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
  Txn.create(
    name: "Book Interest",
    product_uuid: 4,
    date: date,
    debits: { accrued_interest: 40 },
    credits: { interest_income: 40 },
  )
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
  Txn.create(
    name: "Book Interest",
    product_uuid: 4,
    date: date,
    debits: { accrued_interest: 40 },
    credits: { interest_income: 40 },
  )
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
  Txn.create(
    name: "Book Interest",
    product_uuid: 4,
    date: date,
    debits: { accrued_interest: 10 },
    credits: { interest_income: 10 },
  )
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
