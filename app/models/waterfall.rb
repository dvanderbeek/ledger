class Waterfall < ActiveRecord::Base
  belongs_to :action
  belongs_to :debit_account, class_name: Account
  belongs_to :credit_account, class_name: Account
  belongs_to :from_account, class_name: Account

  default_scope { order(:order) }

  def trigger(amount_cents, inputs)
    balance = from_account.balance(as_of: inputs[:date], for_product: inputs[:product_uuid])
    amount_to_allocate = [balance, amount_cents].min
    Txn.create(
      name: action.event.name,
      product_uuid: inputs[:product_uuid],
      date: inputs[:date],
      debits: { debit_account.name.to_sym => amount_to_allocate },
      credits: { credit_account.name.to_sym => amount_to_allocate },
    )
    return amount_to_allocate
  end
end
