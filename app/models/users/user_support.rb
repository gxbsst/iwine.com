module Users
  module UserSupport
    include Users::Helpers::FriendHelperMethods
    include Users::Helpers::TimelineHelperMethods
    include Users::Helpers::ConfigHelperMethods
    include Users::Helpers::EventHelperMethods

    module ClassMethods

    end

    module InstanceMethods

      # 用户更新密码需要输入原始密码
      def update_with_password(params={})

        current_password = params[:current_password] if !params[:current_password].blank?

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end

        result = if has_no_password?  || valid_password?(current_password)
                   update_attributes(params) 
                 else
                   self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                   self.attributes = params
                   false
                 end

        clean_up_passwords
        result
      end

      # 判断用户是否已经关注酒或者酒庄或者其他
      def is_following_resource? resource
        followable_type, followable_id = [resource.class.to_s, resource.id]
        return follows.where(:followable_type => followable_type, :followable_id => followable_id).first
      end

      # 关注酒或者酒庄或者其他
      def following_resource resource
        if is_following_resource? resource
          false
        else
          followable_type, followable_id = [resource.class.to_s, resource.id]
          follows.create(:followable_type => followable_type, :followable_id => followable_id)
        end
      end

    end # end InstanceMethods

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
