class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	has_many :teams
	has_many :tournaments
  has_many :games
  has_many :fields
  has_many :timeslots
  has_many :players
end
