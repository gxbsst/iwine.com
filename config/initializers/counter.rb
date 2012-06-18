module Counter
  module ClassMethods

    def counts(params = {}) # counts :photos_count => {:with => "WinePhotos", :on => [:create, :update], :if => {}}
      # process per field
      params.each do |count_field, param|
        raise ArgumentError, "Argument :with is mandatory" unless param.has_key?(:with)
        raise ArgumentError, "Argument :on is mandatory" unless param.has_key?(:on)
        # raise ArgumentError, "Argument :for is mandatory" unless param.has_key?(:for)
        listener = param[:with] # e.g: Instance of Comment OR Photo
        receiver = param[:receiver] # e.g: instance of wine_detail ...
        event = param[:on]
        method_name = :"#{self.to_s.split('::').first.downcase}_#{count_field}_after_#{event}"
        delete_method_name = :"#{self.to_s.split('::').first.downcase}_#{count_field}_after_delete"
        update_method_name = :"#{self.to_s.split('::').first.downcase}_#{count_field}_after_update"
        # define callback function add
        # __counts + 1
        listener.classify.constantize.instance_eval do
          define_method(method_name) do
           receiver_instance = receiver.call(self) # will commentable or imageable
           receiver_instance.update_attribute(count_field, receiver_instance.send(count_field) + 1)
          end
          # __count - 1
          define_method(delete_method_name) do 
            receiver_instance = receiver.call(self)
            receiver_instance.update_attribute(count_field, receiver_instance.send(count_field) - 1)
          end

          # _count -1 for deleted_at is not null
          define_method(update_method_name) do 
            #### For DELETE
            receiver_instance = receiver.call(self)
            if self.respond_to? "deleted_at" 
              if !deleted_at.blank?
                receiver_instance.update_attribute(count_field, receiver_instance.send(count_field) - 1) unless self.deleted_at.blank?
              end
            end
            #### FOR AUDIT LOG 
            #### Will Be Photo, Wine 
            if self.respond_to? "audit_status" 
              if !audit_status.blank? 
                if audit_status !=  1 #TODO: Update 1 form data.yml
                  receiver_instance.update_attribute(count_field, receiver_instance.send(count_field) - 1) unless self.deleted_at.blank?
                end
              end
            end

          end

        end
        listener.classify.constantize.send(:"after_#{event}", method_name, :if => param[:if])
        listener.classify.constantize.send(:after_destroy, delete_method_name, :if => param[:if] )
        listener.classify.constantize.send(:after_update, update_method_name, :if => param[:if] )
      end
    end

  end

  module InstanceMethods

  end

  def self.included(receiver)

    receiver.extend ClassMethods

  end
  
end



ActiveSupport.on_load :active_record do
  send(:include, Counter)
end
