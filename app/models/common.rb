module Common
  # instance methods

  #废用方法
  # def is_followed? user
  #   return comments.where("user_id = ? and do = ? and deleted_at is null", user.id, 'follow').first ? true : false
  # end

  # def find_follow user
  #   comments.where("user_id = ? and do = ? and deleted_at is null", user.id, 'follow').first
  # end

  def region_path_zh(options = {})
    region_trees = get_region_path
    return nil if region_trees.blank?
    options[:connector] = ">" unless options.has_key? :connector
    region_trees.collect{|r| r.name_zh }.join(options[:connector] )
  end

  def region_path_en(options = {})
    region_trees = get_region_path
    return nil if region_trees.blank?
    options[:connector] = ">" unless options.has_key? :connector
    region_trees.collect{|r| r.origin_name }.join(options[:connector] )
  end


  def get_region_path
    return nil if region_tree_id.blank? || Wines::RegionTree.where("id = #{region_tree_id}").blank?
    region = Wines::RegionTree.find(region_tree_id)
    parent = region.parent
    path = [region]
    until parent == nil
      path << parent
      parent = parent.parent
    end
    path.reverse!
  end
end