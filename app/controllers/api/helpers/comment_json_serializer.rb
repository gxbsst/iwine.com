# encoding: utf-8
module Api::Helpers
  module CommentJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, CommentsError.new(status)).to_json
    end

  end
end