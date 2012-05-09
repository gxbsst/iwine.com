# encoding: utf-8
class CommentsController < ApplicationController
  # before_filter :find_model, :only => [:show, :edit, :update, :destroy]
  before_filter :get_parent_resource
  
   # GET /models
   # GET /models.xml
   def index
     @comments = @parent_resource.comments
     
     # @models = Model.all

     # respond_to do |wants|
     #    wants.html # index.html.erb
     #    wants.xml  { render :xml => @models }
     #  end
   end

   # GET /models/1
   # GET /models/1.xml
   def show
     respond_to do |wants|
        wants.html # show.html.erb
        wants.xml  { render :xml => @model }
      end
   end

   # GET /models/new
   # GET /models/new.xml
   def new
     @model = Model.new

     respond_to do |wants|
        wants.html # new.html.erb
        wants.xml  { render :xml => @model }
      end
   end

   # GET /models/1/edit
   def edit
   end

   # POST /models
   # POST /models.xml
   def create
     @model = Model.new(params[:model])

     respond_to do |wants|
        if @model.save
          flash[:notice] = 'Model was successfully created.'
          wants.html { redirect_to(@model) }
          wants.xml  { render :xml => @model, :status => :created, :location => @model }
        else
          wants.html { render :action => "new" }
          wants.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
        end
      end
   end

   # PUT /models/1
   # PUT /models/1.xml
   def update
     respond_to do |wants|
        if @model.update_attributes(params[:model])
          flash[:notice] = 'Model was successfully updated.'
          wants.html { redirect_to(@model) }
          wants.xml  { head :ok }
        else
          wants.html { render :action => "edit" }
          wants.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
        end
      end
   end

   # DELETE /models/1
   # DELETE /models/1.xml
   def destroy
     @model.destroy

     respond_to do |wants|
        wants.html { redirect_to(models_url) }
        wants.xml  { head :ok }
      end
   end

   private
   def find_model
     @model = Model.find(params[:id])
   end
   
   def get_parent_resource
    if params[:user_id].present?
      @parent_resource = User.find(params[:user_id])
    end
   end

end
