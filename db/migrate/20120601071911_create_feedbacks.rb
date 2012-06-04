class CreateFeedbacks < ActiveRecord::Migration
	def change
		create_table :feedbacks do |t|
			t.string :subject
			t.text :description
			t.string :email, :limit => 64
			t.string :name, :limit => 64
			t.string :type, :limit => 32
			t.timestamps
		end
	end
end
