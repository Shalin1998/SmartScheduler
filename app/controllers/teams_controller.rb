class TeamsController < ApplicationController
	before_action :authenticate_user!
	def new
		@team = Team.new
	end

	def show
		@team = Team.find(params[:id])
	end

	def destroy
		@team = Team.find(params[:id])
		Game.where('team_one=? OR team_two=?', @team.id, @team.id).destroy_all
		@team.destroy
		redirect_to root_path
	end

	def create
		@team = Team.new(team_params)
		@team.user = current_user
		if @team.save
			redirect_to @team
		else
			render 'new'
		end
	end

	private
		def team_params
			params.require(:team).permit(:name)
		end
end
