module Users
  module UserSupport
    def self.included(base)
      base.table_name = 'user_' + base.table_name unless base.table_name =~/^user\_/
      base.extend ClassMethods
    end

    # Class Methods
    module ClassMethods
      

      
    end
  end
end