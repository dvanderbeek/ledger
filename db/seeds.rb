Account::Asset.create([
  { name: :accrued_interest },
  { name: :principal_receivable },
  { name: :interest_receivable },
  { name: :pending_principal },
  { name: :pending_interest },
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

(Date.new(2015, 1, 2)..Date.new(2015, 3, 15)).each do |date|
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

installment_date = Date.new(2015, 3, 1)
late_payment_date = Date.new(2015, 3, 5)
# payment = 2000
# interest = Account.balance([:accrued_interest, :interest_receivable], for_product: 1, as_of: installment_date) # 1400
# principal = payment - interest # 600
Txn.create(
  name: "Book Installment",
  product_uuid: 1,
  date: installment_date,
  debits: {
    interest_receivable: 1400,
    principal_receivable: 600,
  },
  credits: {
    accrued_interest: 1400,
    principal: 600,
  },
)

# accrued_interest = Account.balance(:accrued_interest, for_product: 1, as_of: late_payment_date) # 1400
# interest_receivable = Account.balance(:interest_receivable, for_product: 1, as_of: late_payment_date) # 200
# total_interest = Account.balance([:accrued_interest, :interest_receivable], for_product: 1, as_of: late_payment_date) # 1600
# principal = payment - total_interest # 400
Txn.create(
  name: "Initiate Payment",
  product_uuid: 1,
  date: late_payment_date,
  debits: {
    pending_interest: 1600,
    pending_principal: 400,
  },
  credits: {
    accrued_interest: 1400,
    interest_receivable: 200,
    principal_receivable: 400,
  }
)

Txn.create(
  name: "Process Payment",
  product_uuid: 1,
  date: late_payment_date + 2.days,
  debits: { cash: 2000 },
  credits: {
    pending_interest: 1600,
    pending_principal: 400,
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
  debits: { pending_principal: 7500 },
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
  debits: { pending_principal: 7500 },
  credits: { principal_receivable: 7500 },
)

Txn.create(
  name: "Process Payment",
  product_uuid: 2,
  date: Date.new(2015, 5, 3),
  debits: { cash: 7500 },
  credits: { pending_principal: 7500 },
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
