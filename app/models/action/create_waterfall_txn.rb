class Action
  class CreateWaterfallTxn < ::Action
    has_many :waterfalls, inverse_of: :action, foreign_key: :action_id

    def trigger(inputs)
      amount_remaining = inputs[:amount_cents]
      waterfalls.each do |waterfall|
        amount_allocated = amount_remaining > 0 ? waterfall.trigger(amount_remaining, inputs) : 0
        amount_remaining = [amount_remaining - amount_allocated, 0].max
      end
    end
  end
end
