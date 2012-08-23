module Counter
  class Railtie < Rails::Railtie
    initializer 'counter.class_methods' do
      ActiveSupport.on_load :active_record do
        extend ClassMethods
      end
    end
  end
end
