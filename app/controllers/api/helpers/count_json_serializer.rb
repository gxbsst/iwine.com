# encoding: utf-8
module Api::Helpers
  module CountJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, CountsError.new(status)).to_json
    end

  end
end