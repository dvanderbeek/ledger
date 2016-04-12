class Waterfall < ActiveRecord::Base
  belongs_to :action
  belongs_to :debit_account, class_name: Account
  belongs_to :credit_account, class_name: Account
  belongs_to :from_account, class_name: Account

  default_scope { order(:order) }

  def trigger(amount_cents, inputs)
    @amount_cents = amount_cents
    @inputs = inputs
    Txn.create(
      name: action.event.name,
      product_uuid: inputs[:product_uuid],
      date: inputs[:date],
      debits: { debit_account.name.to_sym => amount_to_allocate },
      credits: { credit_account.name.to_sym => amount_to_allocate },
    )
    return amount_to_allocate
  end

  def balance
    @balance ||= if self == action.waterfalls.last
      @amount_cents
    else
      from_account.balance(as_of: @inputs[:date], for_product: @inputs[:product_uuid])
    end
  end

  def amount_to_allocate
    @amount_to_allocate ||= [balance, @amount_cents].min
  end
end
