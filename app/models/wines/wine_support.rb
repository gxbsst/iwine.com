module Wines
   module WineSupport

     def self.included(base)
       base.table_name = 'wine_' + base.table_name unless base.table_name =~/^wine\_/
       base.extend ClassMethods
     end
    
     def all_vintage
       Wines::Detail.where(["wine_id = ?", id]).select(:year).collect{|i| i.year }
     end

     # Class Methods
     module ClassMethods

       # Wine 项目要用到的公共 class methods
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


   end
end