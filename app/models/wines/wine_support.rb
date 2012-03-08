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

   end
end