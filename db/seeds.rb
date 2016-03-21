Asset.create([
  { name: :interest_receivable },
  { name: :accounts_receivable },
  { name: :cash },
  { name: :loans },
])

Revenue.create([
  { name: :interest_income },
])

Equity.create(name: :equity)
