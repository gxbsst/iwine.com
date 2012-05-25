module Wines
   module WineSupport

     def self.included(base)
       base.table_name = 'wine_' + base.table_name unless base.table_name =~/^wine\_/
       base.extend ClassMethods
     end
    
     def all_vintage
       Wines::Detail.where(["wine_id = ?", wine_id]).select("year, id")
     end

     # Class Methods
     module ClassMethods

       # Wine 项目要用到的公共 class methods
       def timeline_events
         TimelineEvent.wine_details
       end
       
     end

     def region_path_zh(region_tree_id, options = {})
       region_trees = get_region_path(region_tree_id)
       options[:connector] = "-" unless options.has_key? :connector
       region_trees.collect{|r| r.name_zh }.join(options[:connector] )
     end
     
     def region_path_en(region_tree_id, options = {})
       region_trees = get_region_path(region_tree_id)
       options[:connector] = "-" unless options.has_key? :connector
       region_trees.collect{|r| r.name_en }.join(options[:connector] )
     end
     

     def get_region_path(region_tree_id)
       region = Wines::RegionTree.find(region_tree_id)
       parent = region.parent
       path = [region]
       until parent == nil
         path << parent
         parent = parent.parent
       end
       path.reverse!
     end

     def drinkable
       "#{drinkable_begin.strftime('%Y') if drinkable_begin}-#{drinkable_end.strftime('%Y') if drinkable_end}"
     end

     # 当前关注该支酒的用户列表
     def followers(options = { })
       User.joins(:comments).
         where("commentable_type = ? and commentable_id = ? and do = ? and deleted_at is null", self.class.name, id, 'follow').
         page(options[:page] || 1).
         per(options[:per] || 16) #如果想使用limit而不用分页效果可以使用per
     end
     
     # 官方网站
     def html_official_site
       "http://" + official_site
     end
   end
end