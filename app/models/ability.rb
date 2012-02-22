class Ability
  include CanCan::Ability

   def initialize(user)
    user ||= User.new # guest user
    if user.role? :vip
      can :index, :all
    else user.role? :normal

    end
  end
end