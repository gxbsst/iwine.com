module UserJsonSerializer

  DEFAULT_JSON = {
      :success => 1,
      :resultCode => 200,
      :user => '',
      :message => ''
  }

  def self.build_user(user)
    { :auth_token => user.authentication_token,
      :id => user.id,
      :email => user.email,
      :username => user.username,
      :slug => user.slug,
      :avatar => user.avatar.url(:large) + "?t=#{user.updated_at.to_i}",
      :city => user.city ? user.city : "",
      :bio => user.profile.bio ? user.profile.bio : "",
      :phone_number => user.profile.phone_number ? user.profile.phone_number : '',
      :birthday => user.profile.birthday ? user.profile.birthday : '',
      :profile_id => user.profile.id
    }
  end

  class RegistrationJsonSerializer
    def self.as_json user
      error = ErrorValue::UserRegisterError.build(user)
      result = {}
      if user.errors.present?
        result = {:success => error.success, :resultCode => error.code, :message => error.message}
      else
        result = {
            :success => error.success,
            :resultCode => error.code,
            :message => error.message,
            :user => {
                :email => user.email,
                :username => user.username,
                :confirmation_token => user.confirmation_token,
                :id => user.id
            }
        }
      end
      DEFAULT_JSON.merge(result)
    end
  end

  class SessionJsonSerializer
    def self.as_json(user, valid = false)
      error = ErrorValue::UserSessionError.build(user, valid)
      result = {}
      if valid
        result = {
            :success => error.success,
            :resultCode => error.code,
            :message => error.message,
            :user => UserJsonSerializer.build_user(user)
        }
      else
        result = {
            :success => error.success,
            :resultCode => error.code,
            :message => error.message
        }
      end
      DEFAULT_JSON.merge(result)
    end
  end

end