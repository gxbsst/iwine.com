module Users::Helpers::FriendHelperMethods

  module ClassMethods

  end

  module InstanceMethods
    # 关注某人
    def follow_user(user_id)
      unless is_following user_id
        user = User.find(user_id)
        friendship = Friendship.create(:user_id => user.id, :follower_id => id)
      else
        false
      end
    end

    # 取消关注
    def unfollow(user)
      friendship = Friendship.where(:user_id => user.id, :follower_id => id)
      if !friendship.blank?
        Friendship.destroy(friendship.first.id)    
      else
        false
      end
    end

    # 判断是否已经关注某人
    def is_following user_id
      return true if id == user_id
      user = User.find(user_id)
      Friendship.first :conditions => { :user_id => user.id , :follower_id => id }
    end

    def remove_followings sns_friends
      users = []
      sns_friends.each do |f|
        if !is_following f.user_id
          users.push( f )
        end
      end
      users
    end

    def remove_followings_from_user data
      users = []
      data.each do |f|
        if !is_following f.id
          users.push( f )
        end
      end
      users
    end

  end # end InstanceMethods

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
