module Common
  # instance methods

  #废用方法
  # def is_followed? user
  #   return comments.where("user_id = ? and do = ? and deleted_at is null", user.id, 'follow').first ? true : false
  # end

  # def find_follow user
  #   comments.where("user_id = ? and do = ? and deleted_at is null", user.id, 'follow').first
  # end
  #获取 current comments_count

  def current_comments_count
    self.class.where("id = ?", id).select('id, comments_count').first.comments_count
  end

  def current_followers_count
    self.class.where("id = ?", id).select('id, followers_count').first.followers_count
  end

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
  
  #更新酒庄和酒时执行
  def init_cn_names
    name_zh_arr = get_name_arr
    name_zh_arr.each do |name|
      self.cn_names.where(:name_zh => name).
        first_or_create(:name_zh => name)
    end
  end
  
  #将酒和酒庄的name_zh和other_cn_name 加载到一个数组里
  def get_name_arr
    name_arr = []
    name_arr << name_zh if name_zh.present?
    name_arr << other_cn_name.split('/') if other_cn_name.present?
    final_name = name_arr.flatten.uniq.compact
  end
end