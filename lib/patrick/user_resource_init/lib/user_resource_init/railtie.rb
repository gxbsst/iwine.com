module UserResourceInit
  class Railtie < Rails::Railtie
    initializer 'user_resource_init.user_additions' do
      ActiveSupport.on_load :active_record do
        extend UserAdditions
      end
    end
  end
end
