class Event < ActiveRecord::Base
  has_many :actions

  scope :named, -> (name) { find_by(name: name) }

  def trigger(inputs = {})
    inputs[:date] ||= Date.current
    actions.each { |action| action.trigger(inputs) }
  end
end
