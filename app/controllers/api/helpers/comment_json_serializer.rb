# encoding: utf-8
module Api::Helpers
  module CommentJsonSerializer

    def self.as_json(resource = "", status = "")
      if resource.is_a? ActiveRecord::Relation
        Result.new(build_comment_with_user(resource), CommentsError.new(status)).to_json
      else
        Result.new(resource, CommentsError.new(status)).to_json
      end
    end

    def self.build_comment_with_user(resource)

      result = []
      resource.each do |i|
        result << CommentWithUser.generate(i)
      end  if resource.present?
      result
    end

    class CommentWithUser < Struct.new(:user_id, :avatar, :username, :body, :created_at)

      def self.generate(resource)
        new(resource).data
      end

      def initialize(resource)
        self.user_id = resource.user_id
        self.avatar = resource.user.avatar.url(:large)
        self.username = resource.user.username
        self.body = resource.body
        self.created_at = resource.created_at.to_i
      end

      def data
        self
      end

    end

  end
end