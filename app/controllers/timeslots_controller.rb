class TimeslotsController < ApplicationController
  before_action :authenticate_user!
  def new
    @timeslot = Timeslot.new
  end
  def create
    @timeslot = Timeslot.create(timeslot_params)
		@timeslot.user = current_user
    @timeslot.field_id = params[:field_id]
      if @timeslot.save
        redirect_to field_path(params[:field_id])
		    else
          render :new
		    end
  end
  private
    def timeslot_params
      params.require(:timeslot).permit(:start)
		end
end
