# encoding: utf-8
module Api::Helpers
  module VoteJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, VotesError.new(status)).to_json
    end

  end
end