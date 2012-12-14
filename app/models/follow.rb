class Follow < ActiveRecord::Base
  attr_accessible :followable_id, :followable_type, :is_share, :private_type, :user_id
  belongs_to :followable, :polymorphic => true
  belongs_to :user
  validates :followable_type, :followable_id, :user_id, :presence => true
  scope :recent, lambda { |limit| order("created_at DESC").limit(limit) }
  after_create :change_followable_id

  def change_followable_id
    self.update_attribute(:followable_id, Note.find(followable_id).app_note_id) if followable_type == "Note"
  end

  def followable
    if followable_type == 'Note'
      note = Note.find_by_app_note_id(commentable_id)
      Note.sync_note_base_app_note_id(commentable_id)
    else
      super
    end
    #followable_type == "Note" ? Note.find_by_app_note_id(followable_id) : super
  end
 # COUNTER
 # increment
 def follow_counter_should_increment_for(followable_type)
   if self.followable_type == followable_type 
     true
   end
 end

 # decrement
 def follow_counter_should_decrement_for(followable_type)
   if self.followable_type == followable_type 
     true
   end
 end

 # Class Methods
 class << self
   def get_my_follow_item(followable_type,followable_id, user_id)
    find_by_followable_type_and_followable_id_and_user_id(followable_type, followable_id, user_id) 
   end
 end

end
