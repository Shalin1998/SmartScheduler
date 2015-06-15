class Timeslot < ActiveRecord::Base
  belongs_to :field
  belongs_to :user
  validates :start, presence: true
end
