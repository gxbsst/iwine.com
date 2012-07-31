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
    q = "#{params[:query]}%"
    #region = Wines::RegionTree.arel_table
    #regions = Wines::RegionTree.where(region[:name_en].matches(q)).select([:name_en,:id])
    regions = Wines::RegionTree.where("name_en like ?", q)
    result = init_json_result(regions)
    regions_child_ids = get_regions_child_ids(regions)
    new_regions = Wines::RegionTree.order("level, name_en").find(regions_child_ids)
    new_regions.each  do |region|
      begin 
        result[region.root_parent_id]['children'] << region
      rescue Exception => e
        puts e
      end
    end

    render :json => result.inject([]) {|memo, (k, v)| memo << v}
  end

  protected

  # return array
  def get_regions_child_ids(regions)
   child_ids = [] 
   regions.each { |region| child_ids.concat region.get_child_ids }
   child_ids.uniq
  end

  # return hash
  # {1 => {"current_region_id" => 1, "level" => 2} }
  def init_json_result(regions)
   result = regions.inject({}) do |memo, region| 
     root_parent_id = region.root_parent_id
     level = region.level

     # 如果有相同的parent_id, 则取level 比较小的
     if memo.has_key? root_parent_id
       unless level > memo[root_parent_id]['level']
         memo[region.root_parent_id] = {'current_region_id' => region.id, 
         'level' => region.level,
         'origin_name' => region.origin_name,
         'children' => []}
       end
     else
       memo[region.root_parent_id] = {'current_region_id' => region.id, 
         'level' => region.level,
         'origin_name' => region.origin_name,
         'children' => []}
     end
     memo
   end
  end

end
