# encoding: utf-8
module Counter
  module ClassMethods

    def counts(params = {}) # counts :photos_count => {:with => "WinePhotos", :on => [:create, :update], :if => {}}
      # process per field
      params.each do |count_field, param|
        raise ArgumentError, "Argument :with is mandatory" unless param.has_key?(:with)
        raise ArgumentError, "Argument :receiver is mandatory" unless param.has_key?(:receiver)
        raise ArgumentError, "Argument :increment is mandatory" unless param.has_key?(:increment)
        raise ArgumentError, "Argument :decrement is mandatory" unless param.has_key?(:decrement)

        # raise ArgumentError, "Argument :for is mandatory" unless param.has_key?(:for)
        listener              = param[:with] # e.g: Instance of Comment OR Photo
        receiver              = param[:receiver] # e.g: instance of wine_detail ...
        increment_event       = param[:increment][:on]
        decrement_event       = param[:decrement][:on]
        increment_if          = param[:increment][:if]
        decrement_if          = param[:decrement][:if]

        increment_method_name = :"#{self.to_s.split('::').first.downcase}_#{count_field}_after_#{increment_event}"
        decrement_method_name = :"#{self.to_s.split('::').first.downcase}_#{count_field}_after_#{decrement_event}"

        listener.classify.constantize.instance_eval do

          ## INCREMENT METHOD
          define_method(increment_method_name) do
            receiver_instance = receiver.call(self) # will commentable or imageable
            receiver_instance.class.increment_counter(count_field, receiver_instance.id)
          end

          # ## DECREMENT METHOD
          define_method(decrement_method_name) do
            receiver_instance = receiver.call(self)
            receiver_instance.class.decrement_counter(count_field, receiver_instance.id)
          end

        end

        listener.classify.constantize.send(:"after_#{increment_event}", increment_method_name, :if => increment_if)
        listener.classify.constantize.send(:"after_#{decrement_event}", decrement_method_name, :if => decrement_if)

      end ## end each
    end ## end counts

  end
end
