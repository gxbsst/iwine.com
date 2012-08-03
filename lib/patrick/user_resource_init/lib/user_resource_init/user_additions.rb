module UserResourceInit
  module UserAdditions

    # object maybe :profile, :photos
    def init_resources(*class_name)
      # init_resources
      after_create do
        class_name.each do |c|
          if c == "Album"
            eval(c).send("create", :user_id => id, :created_by => id, :name => "#{id}_Album", :is_order_asc => 0)
          else
            eval(c).send("create", :user_id => id)
          end
        end
      end # end after_save
    end

  end
end
