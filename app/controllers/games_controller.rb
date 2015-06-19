class GamesController < ApplicationController
  before_action :authenticate_user!
  extend SimpleCalendar
  has_calendar :attribute => :date_time
  def new
    @game = Game.new
    if user_signed_in?
      @team = current_user.teams.all
    end
  end

  def newscore
    @game = Game.find(params[:id])
    @game.update
  end

  def update
    @game = Game.find(params[:id])
    if @game.update(game_params)
      redirect_to root_path
    else
      render :nothing
    end
  end

  def create
    @game = Game.new(game_params)
    @game.user = current_user
    @game.tournament_id = params[:tournament_id]
    if @game.save
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def show
    @game = Game.find(params[:id])
  end

  private
    def game_params
      params.require(:game).permit(:team_one, :team_two, :date_time, :field_id)
    end
end
