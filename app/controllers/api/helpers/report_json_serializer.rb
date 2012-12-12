# encoding: utf-8
module Api::Helpers
  module ReportJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, ReporstError.new(status)).to_json
    end

  end
end