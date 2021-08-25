class UsersController < ApplicationController
  before_action :authenticate_admin
  before_action :get_users, only: [:index, :create]
  before_action :find_user, only: [:show, :update, :destroy]

  def index
    @user = current_user.franchise.users.new
  end

  def show
  end

  def create
    @user = User.new user_params
    @user.franchise_id = current_user.franchise.id if @user.franchise_id.nil?
    if @user.save
      UserMailer.welcome(@user).deliver_later
      redirect_to users_path
    else
      render :index, user: @user
    end
  end

  def update
    if @user.update user_params
      redirect_to @user
    else
      render :show, user: @user
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(:franchise_id, :email, :first_name, :last_name, :nutritionist)
  end

  def get_users
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @users = User.all.where(franchise_id: params[:franchise_id])
      else
        @users = User.all
      end
    else
      @users = current_user.franchise.users
    end
  end

  def find_user
    if current_user.superuser
      @user = User.find params[:id]
    else
      @user = current_user.franchise.users.find(params[:id])
    end
  end
end
