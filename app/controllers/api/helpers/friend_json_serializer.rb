module Api::Helpers
  module FriendJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, FriendsError.new(status)).to_json
    end

  end
end