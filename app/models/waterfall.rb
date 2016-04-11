class Waterfall < ActiveRecord::Base
  belongs_to :action
  belongs_to :from_account, class_name: Account
  belongs_to :to_account, class_name: Account

  default_scope { order(:order) }

  def trigger(inputs)
    # TODO: change debits / credits to increases / decreases
    #  Figure out amount based on account balance
    #  And send remaining amount to next watefall
    Txn.create(
      name: action.event.name,
      product_uuid: inputs[:product_uuid],
      date: inputs[:date],
      debits: { to_account.name.to_sym => inputs[:amount_cents] },
      credits: { from_account.name.to_sym => inputs[:amount_cents] },
    )
  end
end
