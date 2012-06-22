class WineFollow < ::Follow
	fires :new_follow,  :on              => :create,
	                    :actor           => :user,
	                    :secondary_actor => :followable,
	                    :if => lambda {|wine_follow| wine_follow.is_share}

end
