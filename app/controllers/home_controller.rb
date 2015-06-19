class HomeController < ApplicationController
	require 'roo'
	def welcome
	end

	def import
		file = params[:file]
		ss = Roo::Spreadsheet.open(file.path)
		sheet = ss.sheets
		ss.sheet(sheet.index('Teams')).column(1)[1..-1].each do |t_name|
			Team.create(:name => t_name, :user => current_user).save
		end
		field_sheet = ss.sheet(sheet.index('Fields'))
		field_count = field_sheet.column(1).count

		for i in 2..field_count
			row = field_sheet.row(i)
			row_count = row.count
			field_name = row[0]
			field_location = row[1]
			f = Field.create(:name => field_name, :location => field_location, :user => current_user)
			if f.save
				for n in 2..(row_count -1)
					if !row[n].nil?
						timeslot_start = row[n]
						start = Time.zone.parse(timeslot_start)
						Timeslot.create(:start => start, :field_id => f.id, :user => current_user)
					end
				end
			end
		end
		redirect_to root_path
	end

	def index
		if user_signed_in?
			@tournament = current_user.tournaments.all
			@team = current_user.teams.all
			@game = current_user.games.all.order(date_time: :asc)
			@field = current_user.fields.all
			@game = current_user.games.all
		else
			render :welcome
		end
  end
end
