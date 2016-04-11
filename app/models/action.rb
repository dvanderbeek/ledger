class Action < ActiveRecord::Base
  belongs_to :event

  # TODO: need subclass for create_txn action that validates inputs and has waterfall logic
  has_many :waterfalls

  def trigger(inputs)
    waterfalls.each do |waterfall|
      waterfall.trigger(inputs)
      puts "Triggered ACTION #{self.name} WATERFALL #{waterfall.order} with #{inputs}"
    end
  end
end
