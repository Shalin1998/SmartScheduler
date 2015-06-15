class FieldsController < ApplicationController
  before_action :authenticate_user!
  def show
    @field = Field.find(params[:id])
    @timeslot = Timeslot.new
  end
  def new
    @field = Field.new
  end

  def destroy
    @field = Field.find(params[:id])
    @field.destroy
    redirect_to root_path
  end

  def create
    @field = Field.create(field_params)
    @field.user = current_user
    if @field.save
      redirect_to @field
    else
      render 'new'
    end
  end
  private
    def field_params
      params.require(:field).permit(:name, :location)
    end
end
