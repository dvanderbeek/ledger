class EventsController < ApplicationController
  set_tab :events, :main

  def index
    @events = Event.all.includes(:actions)
  end
end
