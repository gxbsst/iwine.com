# encoding: utf-8
class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :get_event, :only => [:show]

  def new
    @event = Event.new
    @tags = Event.tag_counts_on(:tags)
  
    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @event }
    end
  end

  def create
    @model_class_name = ModelClassName.new(params[:model_class_name])

    respond_to do |wants|
      if @model_class_name.save
        flash[:notice] = 'ModelClassName was successfully created.'
        wants.html { redirect_to(@model_class_name) }
        wants.xml  { render :xml => @model_class_name, :status => :created, :location => @model_class_name }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @model_class_name.errors, :status => :unprocessable_entity }
      end
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
