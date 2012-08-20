
class EventWinesController < ApplicationController
  def new
    @event_wine = EventWine.new
    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @event_wine  }
    end
  end
end
