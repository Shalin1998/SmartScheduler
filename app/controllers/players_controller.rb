class PlayersController < ApplicationController
  before_action :authenticate_user!
	def new
		@player = Player.new
	end

	def show
		@player = Player.find(params[:id])
	end

	def destroy
		@player = Player.find(params[:id])
		team = @player.team_id
    @player.destroy
		redirect_to team_path(team)
	end

  def edit
    @player = Player.find(params[:id])
  end

  def update
    @player = Player.find(params[:id])
    @player.update(name: params[:newname])
    @player.update(email: params[:newemail])
  end

	def create
		@player = Player.new(player_params)
		@player.user = current_user
    @player.team = Team.find(params[:team_id])
    respond_to do |format|
      if @player.save
        # Tell the UserMailer to send a welcome email after save
        PlayerMailer.welcome_email(@player).deliver_now

        format.html { redirect_to(@player.team, notice: 'Player was successfully added.') }
        format.json { render json: @player, status: :created, location: @player }
      else
        format.html { render action: 'new' }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
	end

	private
		def player_params
			params.require(:player).permit(:name, :email)
		end
end
