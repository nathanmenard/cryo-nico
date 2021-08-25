class PasswordsController < ApplicationController
  # before_action :authenticate_franchise
  layout false

  def new
    if request.post?
      if current_franchise
        if client = current_franchise.clients.find_by_email(params[:email])
          ClientMailer.password_forgotten(client).deliver_now
          @success = true
        end
      else
        if user = User.find_by(email: params[:email])
          UserMailer.password_forgotten(user).deliver_now
          @success = true
        end
      end
    end
  end

  def create
    if current_franchise
      @client = find_client_by_private_key(params[:key])
    else
      @user = find_user_by_private_key(params[:key])
    end
    return redirect_to root_path if @client.nil? && @user.nil?
    if request.post?
      if params[:password] != params[:password_2]
        render :new, error: 'PASSWORDS_DO_NOT_MATCH' and return
      end
      if @client.present?
        @client.update(password: params[:password])
        session[:client_id] = @client.id
        redirect_to root_path
      else
        @user.update(password: params[:password])
        session[:user_id] = @user.id
        redirect_to clients_path
      end
    end
  end

  private

  def find_client_by_private_key(key)
    x = nil
    current_franchise.clients.each do |client|
      if key == client.private_key
        x = client
        break
      end
    end
    x
  end

  def find_user_by_private_key(key)
    x = nil
    User.all.each do |user|
      if key == user.private_key
        x = user
        break
      end
    end
    x
  end
end
