class AddPeopleNumToEventParticipants < ActiveRecord::Migration
  def change
    add_column :event_participants, :people_num, :integer, :default => 1
  end
end
