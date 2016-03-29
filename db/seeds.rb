Accounts::Asset.create([
  { name: :accrued_interest },
  { name: :principal_receivable },
  { name: :interest_receivable },
  { name: :pending_payments },
  { name: :cash },
  { name: :principal },
])

Accounts::Revenue.create([
  { name: :interest_income },
])

Accounts::Equity.create([
  { name: :equity },
])

Txn.create(
  name: "Initial Funding",
  date: Date.new(2014, 1, 1),
  debits: { cash: 100000000 },
  credits: { equity: 100000000 },
)

Txn.create(
  name: "Issue Loan",
  product_uuid: 2,
  date: Date.new(2014, 12, 1),
  debits: { principal: 40000 },
  credits: { cash: 40000 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 1, 1),
  debits: { principal_receivable: 10000 },
  credits: { principal: 10000 },
)

Txn.create(
  name: "Start Payment Plan",
  product_uuid: 2,
  date: Date.new(2015, 1, 1),
  debits: { principal: 10000 },
  credits: { principal_receivable: 10000 },
)

Txn.create(
  name: "Process Payment",
  product_uuid: 2,
  date: Date.new(2015, 1, 15),
  debits: { cash: 15000 },
  credits: { principal: 15000 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 2, 1),
  debits: { principal_receivable: 0 },
  credits: { principal: 0 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 3, 1),
  debits: { principal_receivable: 0 },
  credits: { principal: 0 },
)

Txn.create(
  name: "Book Installment",
  product_uuid: 2,
  date: Date.new(2015, 4, 1),
  debits: { principal_receivable: 7500 },
  credits: { principal: 7500 },
)

Txn.create(
  name: "Initiate Payment",
  product_uuid: 2,
  date: Date.new(2015, 4, 1),
  debits: { pending_payments: 7500 },
  credits: { principal_receivable: 7500 },
)

# If payment is processed before it returns, we'd
#   also need to reverse the process payment Txn.
#   Date = date of Txn this is reversing (Initiate Payment).
Txn.create(
  name: "Payment Return",
  product_uuid: 2,
  date: Date.new(2015, 4, 1),
  debits: { principal_receivable: 7500 },
  credits: { pending_payments: 7500 },
)

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
