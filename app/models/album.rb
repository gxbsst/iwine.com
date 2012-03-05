class Album < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'created_by'

  has_many :photos


  
  end