# encoding: utf-8
class CreateEventWines < ActiveRecord::Migration
  def change
    create_table :event_wines do |t|
      t.belongs_to :event
      t.belongs_to :wine_detail

      t.timestamps
    end
    add_index :event_wines, :event_id
    add_index :event_wines, :wine_detail_id
  end
end
