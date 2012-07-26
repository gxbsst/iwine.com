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

  def region_tree
    q = "%#{params[:query]}%"
    #region = Wines::RegionTree.arel_table
    #regions = Wines::RegionTree.where(region[:name_en].matches(q)).select([:name_en,:id])
    regions = Wines::RegionTree.where("name_en like ?", q).select([:name_en, :id])
    resulrt = init_json_result(regions)
    regions_child_ids = get_regions_child_ids(regions)
    
    render :json => regions
  end

  protected

  # return array
  def get_regions_child_ids(regions)
   child_ids = [] 
   regions.each { |region|  region.get_child_ids }
   child_ids.uniq
  end

  # return hash
  def init_json_result(regions)
   result = regions.inject({}) do |memo, region| 
     root_parent_id = region.root_parent_id
     level = region.level

     # 如果有相同的parent_id, 则取level 比较小的
     return if memo.has_key? (root_parent_id && level > memo[root_parent_id]['level'])
     memo[region.root_parent_id] = {'current_region_id' => regiont.id, 'level' => region.level }
     memo
   end
  end

end
