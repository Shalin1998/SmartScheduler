class Field < ActiveRecord::Base
  validates :name, presence: true, uniqueness: {scope: :user_id}
  belongs_to :user
  validates :name, presence: true
  validates :location, presence: true
  has_many :games, :dependent => :destroy
  has_many :timeslots, :dependent => :destroy
end
