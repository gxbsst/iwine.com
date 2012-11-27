module ErrorValue

  class FriendError < Base

    def self.build(user, status)
      new(user, status).parse_error
    end

    def initialize(user, status = true)
      super(user)
      @status = status
    end


    def parse_error
      if @status
        self.success = 1
        self.code =  API_ERROR['friend']['success']['code']
        self.message =  API_ERROR['friend']['success']['message']
      else
        self.success = 0
        self.code =  API_ERROR['friend']['other_failed']['code']
        self.message =  API_ERROR['friend']['other_failed']['message']
      end
      self
    end

  end



end