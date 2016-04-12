class Action
  class CreateTxn < ::Action
    belongs_to :debit_account, class_name: Account
    belongs_to :credit_account, class_name: Account

    def trigger(inputs)
      Txn.create(
        name: event.name,
        product_uuid: inputs[:product_uuid],
        date: inputs[:date],
        debits: { debit_account.name.to_sym => inputs[:amount_cents] },
        credits: { credit_account.name.to_sym => inputs[:amount_cents] },
      )
    end
  end
end
