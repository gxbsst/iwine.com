module Api::Helpers
  module OauthJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, OauthsError.new(status)).to_json
    end

  end
end