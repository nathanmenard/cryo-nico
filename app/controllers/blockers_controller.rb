class BlockersController < ApplicationController
  before_action :authenticate_admin
  before_action :find_blocker, only: [:show, :update, :destroy]

  def create
    @blocker = Blocker.new blocker_params
    @blocker.user = current_user
    @blocker.franchise_id = current_user.franchise.id if @blocker.franchise_id.nil?
    if @blocker.save
      redirect_to reservations_path
    else
      head :bad_request
    end
  end

  def update
    if @blocker.update blocker_params
      redirect_to reservations_path
    else
      head :bad_request
    end
  end

  def destroy
    @blocker.destroy
    head :no_content
  end

  private

  def blocker_params
    params.require(:blocker).permit(:start_time, :end_time, :notes, :blocking, :global, :room_id, :franchise_id)
  end

  def find_blocker
    if current_user.superuser
      @blocker = Blocker.find(params[:id])
    else
      @blocker = current_user.franchise.blockers.find(params[:id])
    end
  end
end
