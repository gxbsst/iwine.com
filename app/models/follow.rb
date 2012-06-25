class Follow < ActiveRecord::Base
  attr_accessible :followable_id, :followable_type, :is_share, :private_type, :user_id
  belongs_to :followable, :polymorphic => true
  belongs_to :user
  validates :followable_type, :followable_id, :user_id, :presence => true
  scope :recent, lambda { |limit| order("created_at DESC").limit(limit) }
 # COUNTER
 # increment
 def wine_follow_counter_should_increment_for(followable_type)
   if self.followable_type == followable_type 
     true
   end
 end

 # decrement
 def wine_follow_counter_should_decrement_for(followable_type)
   if self.followable_type == followable_type 
     true
   end
 end


end
