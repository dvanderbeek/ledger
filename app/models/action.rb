class Action < ActiveRecord::Base
  belongs_to :event

  def trigger
    raise NotImplementedError.new("Subclass must implement .trigger")
  end
end
