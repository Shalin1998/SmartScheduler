class TournamentsController < ApplicationController
	before_action :authenticate_user!

	def show
		@tournament = Tournament.find(params[:id])
		@game = Game.create
		@team = current_user.teams.all
		@field = current_user.fields.all
		@user = current_user


		all_games = Array.new
    same_day = Array.new
    normal_day = Array.new
    @tournament.games.order(date_time: :asc).each do |f|
      all_games.push(f)
    end

    all_games.each do |f|
      all_games.each do |x|
        if f != x && f.date_time.yday == x.date_time.yday
          same_day.push(x)
        end
      end
    end
		check = false
    @game_list = Array.new {Array.new}
    for i in 0..all_games.count-1
			next if i != 0 && all_games[i-1].date_time.yday == all_games[i].date_time.yday
			if check
				check = false
			end
      if i != all_games.count-1
        if all_games[i+1].date_time.yday == all_games[i].date_time.yday
          @game_list.push([all_games[i],all_games[i+1]])
					check = true
        else
          @game_list.push([all_games[i]])
        end
      end
    end
		@game_list.push([all_games[all_games.count-1]])



		@remove_team = Array.new
		teams = Array.new
		@tournament.games.each do |f|
			teams.push(f.team_one).push(f.team_two)
		end
		teams = teams.uniq
		for i in 0..teams.count-1
			@remove_team.push(teams[i])
		end

		@add_team = Array.new
		add_teams = Array.new
		current_user.teams.each do |f|
			add_teams.push(f.id)
		end
		for i in 0..add_teams.count-1
			@remove_team.each do |f|
				if f == add_teams[i]
					add_teams.delete_at(i)
				end
			end
		end
		@add_team = add_teams.uniq
	end

	def add_team
		tournament_num = params[:tournamentid]
		team_arr = params[:teams_selected_add]
		field_arr = params[:fields_selected]

		@current_teams = Array.new
		teams = Array.new
		Tournament.find(tournament_num).games.each do |f|
			teams.push(f.team_one).push(f.team_two)
		end
		teams = teams.uniq
		for i in 0..teams.count-1
			@current_teams.push(teams[i])
		end

		@timeslot_count = 0
		@field_count = field_arr.count
		@game_count = 0
		@team_count = team_arr.count
		for i in 0..(field_arr.count-1)
			Field.find(field_arr[i]).timeslots.each do |f|
				if f.available?
					@timeslot_count += 1
				end
			end
		end
		@game_count = @current_teams.count * @team_count
		if @game_count > @timeslot_count
			@error = true
			@errors_message = "Not enough timeslots!"
		else
			@team_one_arr = Array.new
			@team_two_arr = Array.new
			i = 0
			team_arr.each do |f|
				@team_one_arr.push(f)
			end
			@current_teams.each do |f|
				@team_two_arr.push(f)
			end
			@timeslots_arr = Array.new
			@field_timeslots_arr = Array.new
			f = 0
			for i in 0..(@field_count-1)
				Field.find(field_arr[i]).timeslots.each do |x|
					if x.available?
						@timeslots_arr[f] = x.id
						@field_timeslots_arr[f] = field_arr[i]
						f += 1
					end
				end
			end
			@create_game = Array.new(@game_count){Array.new(4)}
			x = 0
			for i in 0..@game_count-1
				@create_game[i][0] = team_arr[0]
				@create_game[i][1] = @current_teams[x]
				x += 1
			end
			#MORE THAN ONE GAME PER WEEK
			@create_game[0][2] = @timeslots_arr[0]
			@create_game[0][3] = @field_timeslots_arr[0]
			@timeslots_arr.delete_at(0)

			@not_possible = 0
			@error_message_times = false
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
					:date_time => Timeslot.find(@create_game[i][2]).start, :field_id => @create_game[i][3],
					:timeslot => @create_game[i][2])
					Timeslot.find(@create_game[i][2]).update_attribute(:available, false)
				end
				Tournament.find(tournament_num).update_attribute(:generated, true)
				redirect_to tournament_path(tournament_num)
			else
				# add error here
				@errors_message = "The selected timeslots are too close to one another!  Each team playing only once a week is not possible with this configuration!"
			end
		end

	end

	def remove_team
		tournament_num = params[:tournamentid]
		teams_remove = params[:teams_selected_remove]
		x = Array.new
		for i in 0..teams_remove.count-1
			f = Game.where("team_one = #{teams_remove[i]} OR team_two = #{teams_remove[i]}")
			for m in 0..f.count-1
				x.push(f[m].timeslot)
			end
			f.destroy_all
		end
		for i in 0..x.count-1
			Timeslot.find(x[i]).update_attribute(:available, true)
		end
		redirect_to tournament_path(tournament_num)
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
			Field.find(field_arr[i]).timeslots.each do |f|
				if f.available?
					@timeslot_count += 1
				end
			end
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
					if x.available?
						@timeslots_arr[f] = x.id
						@field_timeslots_arr[f] = field_arr[i]
						f += 1
					end
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
					:date_time => Timeslot.find(@create_game[i][2]).start, :field_id => @create_game[i][3],
					:timeslot => @create_game[i][2])
					Timeslot.find(@create_game[i][2]).update_attribute(:available, false)
				end
				Tournament.find(tournament_num).update_attribute(:generated, true)
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
		@tournament.games.each do |f|
			Timeslot.find(f.timeslot).update_attribute(:available, true)
		end
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
