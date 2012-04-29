module UserResourceInit
  module UserAdditions

    # object maybe :profile, :photos
    def init_resources(*class_name)
      # init_resources
      after_create do
          class_name.each do |c|
            eval(c).send("create", :user_id => id)
          end
      end # end after_save
    end

  end
end
