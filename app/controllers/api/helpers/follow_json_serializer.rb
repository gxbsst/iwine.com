# encoding: utf-8
module Api::Helpers
  module FollowJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, FollowsError.new(status)).to_json
    end

  end
end