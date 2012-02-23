module WINES
   module WineSupport

    def self.included(base)
       base.set_table_name 'wine_' + base.table_name unless base.table_name =~/^wine\_/
       base.extend ClassMethods
    end

    # Class Methods
    module ClassMethods
       # Wine 项目要用到的公共 class methods
    end

   end
end