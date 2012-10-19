module Helper
  module EventsControllerHelper
    module ClassMethods

    end

    module InstanceMethods

      protected

      def check_owner
        if current_user.is_owner_of_event? @event 
          true
        else
          render_404('')
        end
      end

      # 登录用户是否关注活动
      def get_follow_item
        if !user_signed_in? 
          nil
        else
          @follow_item = @event.have_been_followed? @user.id
          @follow_item ? @follow_item : nil
        end
      end

      # 登录用户是否已经参加活动
      def get_join_item
        if !user_signed_in? 
          nil
        else
          @participant = @event.have_been_joined? @user.id
          @participant ? @participant : nil
        end
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
