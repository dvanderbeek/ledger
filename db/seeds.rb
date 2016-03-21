Accounts::Asset.create([
  { name: :accrued_interest },
  { name: :accounts_receivable },
  { name: :cash },
  { name: :principal },
])

Accounts::Revenue.create([
  { name: :interest_income },
])

Accounts::Equity.create([
  { name: :equity },
])
