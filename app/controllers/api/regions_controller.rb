class Api::RegionsController < ApplicationController
  respond_to :json
  layout nil
  
  #######################################################
  ## 中国地区
  #######################################################
  
  def locals
    # type = params[:type]
    parent_id = params[:parent_id]
    locals = Region.locals(parent_id).order("id DESC")
    render :json => locals
  end
  
  def china_provinces
    parent_id = params[:parent_id]
    provinces = Region.provinces(parent_id)
    render :json => provinces
  end
  
  def china_cities
    parent_id = params[:parent_id]
    cities = Region.cities(parent_id)
    render :json => cities
  end
  
  def china_districts
     parent_id = params[:parent_id]
     districts = Region.districts(parent_id)
     render :json => districts
  end
  
  #######################################################
  ## 葡萄酒世界产区
  #######################################################
  
  def region_world
    parent_id = params[:parent_id]
    regions = Wines::RegionTree.region(parent_id).order("id DESC")
    render :json => regions
  end
    
end