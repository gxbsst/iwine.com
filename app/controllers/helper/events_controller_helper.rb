module Helper
  module EventsControllerHelper
    module ClassMethods

    end

    module InstanceMethods
      def check_owner
        if current_user.is_owner_of_event? @event 
          true
        else
          render_404('')
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
