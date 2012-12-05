module Api::Helpers
  module FriendJsonSerializer

    def self.as_json(resource = "", status = "")
      Result.new(resource, FriendsError.new(status)).to_json
    end

    #class FollowResponser
    #  #   返回
    #  #1. 关注数／被关注数
    #  #2. 关注状态（是否为互相关注）
    #  #3. 被关注的用户信息
    #  #4. 被关注的人的藏酒
    #  #5. 在user表添加notes_count, 给kim使用
    #  #6. 排名
    #  #7. 勋章
    #
    #  attribute :profile
    #  attribute :cellar_count, Integer, :default => 0
    #  attribute :notes_count, Integer, :default => 0
    #  attribute :decoration  # 勋章
    #  attribute :note_ranking, Integer, :default => 0 # 排名 用户的品酒辞所获积分
    #  attribute :followers_count, Integer, :default => 0 # 被关注数
    #  attribute :friends_count, Integer, :default => 0 # 关注数
    #
    #  def cellar_count
    #    profile.cellar.items_count
    #  end
    #
    #  def followers_count
    #    profile.followers_count
    #  end
    #
    #  def friends_count
    #    profile.followings_count
    #  end
    #
    #end

  end
end