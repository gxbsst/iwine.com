# encoding: utf-8
class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :get_event, :only => [:show]

  def new
    @event = Event.new
    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @event }
    end
  end

  def create
    event = params[:event]
    @event = Event.new(
      :title => event[:title],
      :description => event[:description],
      :begin_at => event[:begin_at],
      :end_at => event[:end_at],
      :block_in=> event[:block_in],
      :tag_list => event[:tag_list],
      :region_id => event[:region_id].to_i,
      :address => event[:address]
    )
    if @event.save
      redirect_to new_event_event_wine_path(@event)
    else
      render :action => :new
    end
  end

  def edit
    @model_class_name = ModelClassName.find(params[:id])
  end

  def update
    @model_class_name = ModelClassName.find(params[:id])
  
    respond_to do |wants|
      if @model_class_name.update_attributes(params[:model_class_name])
        flash[:notice] = 'ModelClassName was successfully updated.'
        wants.html { redirect_to(@model_class_name) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @model_class_name.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @model_class_name = ModelClassName.find(params[:id])
  
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @model_class_name }
    end
  end

  def destroy
    @model_class_name = ModelClassName.find(params[:id])
    @model_class_name.destroy
  
    respond_to do |wants|
      wants.html { redirect_to(model_class_names_url) }
      wants.xml  { head :ok }
    end
  end

  private
  
  def get_event
   @event = Event.find(params[:id]) 
  end
end
