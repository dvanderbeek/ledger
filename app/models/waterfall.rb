class Waterfall < ActiveRecord::Base
  belongs_to :action
  belongs_to :debit_account, class_name: Account
  belongs_to :credit_account, class_name: Account
  belongs_to :from_account, class_name: Account

  default_scope { order(:order) }

  def trigger(amount_cents, inputs, final)
    @amount_cents = amount_cents
    @inputs = inputs
    @final = final
    Txn.create(
      name: action.event.name,
      product_uuid: inputs[:product_uuid],
      date: inputs[:date],
      debits: { debit_account.name.to_sym => amount_to_allocate },
      credits: { credit_account.name.to_sym => amount_to_allocate },
    )
    return amount_to_allocate
  end

  def to_account
    from_account_id == credit_account_id ? debit_account : credit_account
  end

  private

  def amount_to_allocate
    @amount_to_allocate ||= if @final
      @amount_cents
    else
      [balance, @amount_cents].min
    end
  end

  def balance
    @balance ||= from_account.balance(as_of: @inputs[:date], for_product: @inputs[:product_uuid])
  end
end
