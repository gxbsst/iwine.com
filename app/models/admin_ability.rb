class AdminAbility
  #include CanCan::Ability

  def initialize(user)
    #user ||= AdminUser.new
    #case user.role
    #  when "admin"
    #    can :manage, :all
    #  when "editor"
    #    can :manage,Post
    #    cannot [:destroy,:edit], Post
    #end
  end
end