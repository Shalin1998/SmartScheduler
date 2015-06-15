class Tournament < ActiveRecord::Base
	validates_uniqueness_of :name
	validates :name, presence: true
	belongs_to :user
	has_many :games, :dependent => :destroy
end
