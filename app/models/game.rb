class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament
  validates :team_one, presence: true
  validates :team_two, presence: true
  validates :date_time, presence: true
  has_one :field
  belongs_to :field
  after_initialize :init

    def init
      self.team_one_score  ||= 0           #will set the default value only if it's nil
      self.team_one_score  ||= 0
    end
end
