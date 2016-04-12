class Action
  class CreateWaterfallTxn < ::Action
    has_many :waterfalls, inverse_of: :action, foreign_key: :action_id

    def trigger(inputs)
      amount_remaining = inputs[:amount_cents]
      waterfalls.each_with_index do |waterfall, index|
        amount_allocated = amount_remaining > 0 ? waterfall.trigger(amount_remaining, inputs, index == waterfall_count - 1) : 0
        amount_remaining = [amount_remaining - amount_allocated, 0].max
      end
    end

    private

    def waterfall_count
      @waterfall_count ||= waterfalls.count
    end
  end
end
