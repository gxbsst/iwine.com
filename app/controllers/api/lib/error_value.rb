module ErrorValue
  API_ERROR = APP_DATA['api']['return_json']

  class Base
    attr_accessor(:code, :message, :success)
    def self.build(user)
      new(user).parse_error
    end

    def initialize(user)
      @user ||= user
    end
  end

  class UserRegisterError < Base

    def parse_error
      if @user.errors.present?
        self.success = 0
        if @user.errors[:username].present?
          self.code =  API_ERROR['register']['name_existed']['code']
          self.message =  API_ERROR['register']['name_existed']['message']
        elsif @user.errors[:email].present?
          self.code =  API_ERROR['register']['email_existed']['code']
          self.message =  API_ERROR['register']['email_existed']['message']
        else
          self.code =  API_ERROR['register']['other_failed']['code']
          self.message =  API_ERROR['register']['other_failed']['message']
        end
      else
        self.success = 1
        self.code =  API_ERROR['register']['success']['code']
        self.message =  API_ERROR['register']['success']['message']
      end
      self
    end

  end

  class UserSessionError < Base

    def self.build(user, valid)
      new(user, valid).parse_error
    end

    def initialize(user, valid = false)
      super(user)
      @valid = valid
    end

    def parse_error
      if @valid
        self.success = 0
        self.code =  API_ERROR['login']['success']['code']
        self.message =  API_ERROR['login']['success']['message']
      else
        self.success = 1
        self.code =  API_ERROR['login']['other_failed']['code']
        self.message =  API_ERROR['login']['other_failed']['message']
      end
      self
    end

  end

  class UserPasswordError < Base

    def parse_error
      if @user.errors[:email].present?
        self.success = 0
        self.code =  API_ERROR['password']['other_failed']['code']
        self.message =  API_ERROR['password']['other_failed']['message']
      else
        self.success = 1
        self.code =  API_ERROR['password']['success']['code']
        self.message =  API_ERROR['password']['success']['message']
      end
      self
    end

  end

end