class RoomsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_rooms, only: [:index, :create]
  before_action :find_room, only: [:show, :update, :destroy]

  def index
    @room = current_user.franchise.rooms.new
  end

  def show
  end

  def create
    @room = Room.new room_params
    @room.franchise_id = current_user.franchise.id if @room.franchise_id.nil?
    if @room.save
      redirect_to rooms_path
    else
      render :index, room: @room
    end
  end

  def update
    if @room.update room_params
      redirect_to @room
    else
      render :show, room: @room
    end
  end

  def destroy
    @room.destroy
    head :no_content
  end

  private

  def room_params
    params.require(:room).permit(:name, :capacity, :franchise_id)
  end

  def get_rooms
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @rooms = Room.all.where(franchise_id: params[:franchise_id])
      else
        @rooms = Room.all.includes(:franchise)
      end
    else
      @rooms = current_user.franchise.rooms.includes(:franchise)
    end
  end

  def find_room
    if current_user.superuser
      @room = Room.find params[:id]
    else
      @room = current_user.franchise.rooms.find(params[:id])
    end
  end
end
