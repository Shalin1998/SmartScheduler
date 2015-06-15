class TournamentsController < ApplicationController
	before_action :authenticate_user!

	def show
		@tournament = Tournament.find(params[:id])
		@game = Game.create
		@team = current_user.teams.all
		@field = current_user.fields.all
		@user = current_user
		@same_day = Array.new
		i = 0
		@game_arr = Array.new
		@tournament.games.each do |f|
			@game_arr[i] = f.id
			i += 1
		end
		x = 0
		@tournament.games.each do |f|
			for i in 0..@game_arr.count-1
				if(@game_arr[i] != f.id)
					if !(@game_arr[i].nil?) && (f.date_time.yday == Game.find(@game_arr[i]).date_time.yday)
						@same_day[x] = f.id
						@game_arr.delete_at(i)
						x += 1
					end
				end
			end
		end
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
			@errors_message = "Not enough timeslots!"
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
			for i in 0..(@game_count-1)
					@create_game[i][0] = @team_one_arr[i]
					@create_game[i][1] = @team_two_arr[i]
			end
			@create_game[0][2] = @timeslots_arr[0]
			@create_game[0][3] = @field_timeslots_arr[0]
			@timeslots_arr.delete_at(0)

			for i in 1..@game_count-1
				for x in 1..@timeslots_arr.count-1
					@checking = false
					for y in 0..@game_count-1
						if @create_game[i][0] == @create_game[y][0] || @create_game[i][0] == @create_game[y][1] || @create_game[i][1] == @create_game[y][0] || @create_game[i][1] == @create_game[y][1]
							if !@create_game[y][2].nil?
								if (Timeslot.find(@timeslots_arr[x]).start.to_datetime.cweek == Timeslot.find(@create_game[y][2]).start.to_datetime.cweek) && (Timeslot.find(@timeslots_arr[x]).start.to_datetime.year == Timeslot.find(@create_game[y][2]).start.to_datetime.year)
									@checking = true
								end
							end
						end
					end

					if @checking == true
						@not_possible += 1
					else
						@next = false
						for f in 0..@game_count-1
							if !(@create_game[f][2].nil?)
								if @create_game[f][2] == @timeslots_arr[x]
									@next = true
									break
								end
							end
						end
						if @next == false
							@create_game[i][2] = @timeslots_arr[x]
							@create_game[i][3] = @field_timeslots_arr[x]
						end
					end
				end
			end
			@nil_time = false
			for i in 0..(@game_count-1)
				if @create_game[i][2].nil?
					@nil_time = true
				end
			end

			if @nil_time == false
				for i in 0..(@game_count-1)
					Game.create(:user => current_user,
					:tournament => Tournament.find(tournament_num),
					:team_one => @create_game[i][0] , :team_two => @create_game[i][1],
					:date_time => Timeslot.find(@create_game[i][2]).start, :field_id => @create_game[i][3])
				end
				redirect_to tournament_path(tournament_num)
			else
				# add error here
				@errors_message = "The selected timeslots are too close to one another!  Each team playing only once a week is not possible with this configuration!"
			end
		end
	end

	def send_schedule
		team_arr = params[:teams_selected_mail]
		tournament_num = params[:tournamentid]
		for i in 0..team_arr.count-1
			x = Team.find(team_arr[i]).players
			x.each do |f|
				PlayerMailer.schedule_email(f,tournament_num).deliver_now
			end
		end
		redirect_to tournament_path(tournament_num)
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
