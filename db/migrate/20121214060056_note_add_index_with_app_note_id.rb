class NoteAddIndexWithAppNoteId < ActiveRecord::Migration
  def up
    add_index :notes, :app_note_id
  end

  def down
    remove_index :notes, :app_note_id
  end
end
