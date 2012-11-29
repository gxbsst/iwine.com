module FriendJsonSerializer

  DEFAULT_JSON = {
      :success => 1,
      :resultCode => 200,
      :message => ''
  }

  # 关注
  class FollowSerializer

    STATUS = {
        :success => true,
        :failed => false
    }

    def self.as_json(resource, status = STATUS[:success])
      error = ErrorValue::FriendError.build(resource, status)
      user =  FollowResponser.new(:profile => resource)
      result = {
          :success => error.success,
          :resultCode => error.code,
          :message => error.message,
          :user => user
      }
      DEFAULT_JSON.merge(result)
    end
  end

  # 取消关注
  class DestroySerializer
    STATUS = {
        :success => true,
        :failed => false
    }

    def self.as_json(resource, status = STATUS[:success])
      error = ErrorValue::FriendError.build(resource, status)
      user =  FollowResponser.new(:profile => resource)
      result = {
          :success => error.success,
          :resultCode => error.code,
          :message => error.message,
          :user => user
      }
      DEFAULT_JSON.merge(result)
    end

  end

  class FollowResponser
    #   返回
    #1. 关注数／被关注数
    #2. 关注状态（是否为互相关注）
    #3. 被关注的用户信息
    #4. 被关注的人的藏酒
    #5. 在user表添加notes_count, 给kim使用
    #6. 排名
    #7. 勋章

    include ::Virtus

    attribute :profile
    attribute :cellar_count, Integer, :default => 0
    attribute :notes_count, Integer, :default => 0
    attribute :decoration  # 勋章
    attribute :note_ranking, Integer, :default => 0 # 排名 用户的品酒辞所获积分
    attribute :followers_count, Integer, :default => 0 # 被关注数
    attribute :friends_count, Integer, :default => 0 # 关注数

    def cellar_count
      profile.cellar.items_count
    end

    def followers_count
      profile.followers_count
    end

    def friends_count
      profile.followings_count
    end

  end

end