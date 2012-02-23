module USERS
  module UserSupport
    def self.included(base)
      base.set_table_name 'user_' + base.table_name unless base.table_name =~/^user\_/
      base.extend ClassMethods
    end

    # Class Methods
    module ClassMethods
      #  项目要用到的公共 class methods
    end
  end
end