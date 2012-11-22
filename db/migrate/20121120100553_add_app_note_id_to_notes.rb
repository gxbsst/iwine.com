class AddAppNoteIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :app_note_id, :integer
  end
end
