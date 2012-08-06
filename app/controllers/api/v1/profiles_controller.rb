
module Api
  module V1
    class ProfilesController < ::Api::BaseApiController
      before_filter :authenticate_user!
      before_filter :get_user

      # {:user[city] => {:usename => "Weixuhong", 
      # :phone_number => "", 
      # :birthday => "yyyy-MM-dd", 
      # :bio => "..big text.."}}
      def update

        birthday = params[:user][:profile_attributes][:birthday]
        if birthday.present? 
          params[:user][:profile_attributes][:birthday] = Time.parse birthday
        end

        if current_user.update_attributes(params[:user]) &&
          current_user.profile.update_attributes(params[:user][:profile_attributes])
          success_json(current_user)
        else 
          invalid_update_json(current_user) 
        end
      end

      def index
       render :json =>  user_info_json
      end

      protected

      def invalid_update_json(user)
        render :json=> {:success=>false, :message => user.errors.messages , :status => 422 }
      end

      def success_json(user)
        render :json => user_info_json 
      end

      def get_user
       @user = current_user 
      end

    end
  end
end
