class TournamentsController < ApplicationController
	before_action :authenticate_user!

	def show
		@tournament = Tournament.find(params[:id])
		@game = Game.create
		@team = current_user.teams.all
		@field = current_user.fields.all
	end

	def new
		@tournament = Tournament.new
	end

	def schedule
		tournament_num = params[:tournamentid]
		field_arr = params[:fields_selected]
		team_arr = params[:teams_selected]
		@timeslot_count = 0
		@field_count = field_arr.count
		@game_count = 0
		@team_count = team_arr.count
		for i in 0..(field_arr.count-1)
			@timeslot_count += Field.find(field_arr[i]).timeslots.count
		end
		for i in 1..(team_arr.count-1)
			@game_count += i
		end
		if @game_count > @timeslot_count
			@error = true
		else
			@team_one_arr = Array.new
			@team_two_arr = Array.new
			count = 0
			@x = @team_count -1
			m = 1
			y = 0
			for i in 0..(@team_count - 2)
				for n in (count)..(@x+count-1)
					@team_one_arr[n] = team_arr[i]
					count += 1
				end
				for n in m..(@team_count-1)
					@team_two_arr[y] = team_arr[n]
				  y += 1
				end
				m += 1
				@x -= 1
			end
			@timeslots_arr = Array.new
			@field_timeslots_arr = Array.new
			f = 0
			for i in 0..(@field_count-1)
				Field.find(field_arr[i]).timeslots.each do |x|
					@timeslots_arr[f] = x.id
					@field_timeslots_arr[f] = field_arr[i]
					f += 1
				end
			end
			@create_game = Array.new(@game_count){Array.new(4)}
			g = 0
			@not_possible = 0
			@error_message_times = false
			x = @timeslots_arr.count
			for i in 0..(@game_count-1)
				if i == 0
					@create_game[i][0] = @team_one_arr[i]
					@create_game[i][1] = @team_two_arr[i]
					@create_game[i][2] = Timeslot.find(@timeslots_arr[g]).start
					@create_game[i][3] = @field_timeslots_arr[g]
					@timeslots_arr.delete_at(g)
					g += 1
				else
					@create_game[i][0] = @team_one_arr[i]
					@create_game[i][1] = @team_two_arr[i]
					for ix in 0..(@create_game.count-1)
						if @create_game[ix][0] == @create_game[i][0] || @create_game[ix][1] == @create_game[i][1] || @create_game[ix][1] == @create_game[i][0] || @create_game[ix][0] == @create_game[i][1]
							for ii in 0..(@timeslots_arr.count-1)
								if @create_game[i-1][2].to_datetime.cweek == Timeslot.find(@timeslots_arr[g]).start.to_datetime.cweek && @create_game[i-1][2].to_datetime.year == Timeslot.find(@timeslots_arr[g]).start.to_datetime.year
									@not_possible += 1
									g += 1
 								end
							end
						end
					end
					@create_game[i][2] = Timeslot.find(@timeslots_arr[g]).start
					@create_game[i][3] = @field_timeslots_arr[g]
					g = 0
					if g == (@timeslots_arr.count - 1)
						g = 0
					end
					#break if @not_possible >= x+x
				end
			end
			@first_arr = Array.new
			#for i in 0..(@game_count-1)
			#	@first_arr[i] = Game.create(:user => current_user,
			#	:tournament_id => tournament_num,
			#	:team_one => @create_game[i][0] , :team_two => @create_game[i][1],
			#	:date_time => @create_game[i][2], :field_id => @field_timeslots_arr[i])
			#end
		end
	end

	def destroy
		@tournament = Tournament.find(params[:id])
		@tournament.destroy
		redirect_to root_path
	end

	def create
		@tournament = Tournament.create(tournament_params)
		@tournament.user = current_user
		if @tournament.save
			redirect_to root_path
		else

		end
	end

	private
		def tournament_params
			params.require(:tournament).permit(:name)
		end
end
