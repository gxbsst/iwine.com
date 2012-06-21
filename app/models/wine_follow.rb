class WineFollow < ::Follow
	fires :new_follow,  :on              => :create,
	                    :actor           => :user,
	                    :secondary_actor => :followable,

end
