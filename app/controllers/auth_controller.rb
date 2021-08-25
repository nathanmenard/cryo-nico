class AuthController < ApplicationController
  before_action :authenticate_franchise, only: [:signup, :login, :edit_account, :admin_signup]
  before_action :authenticate_client, only: :edit_account

  layout false

  def signup
    if params[:company_id] && params[:key]
      company_clients = current_franchise.companies.find(params[:company_id]).company_clients
      @company_client = company_clients.find_by_private_key(params[:key])
    else
      @client = current_franchise.clients.new
    end
    if request.post?
      if @company_client
        if @company_client.update company_client_params
          session[:company_client_id] = @company_client.id
          @company_client.update last_logged_at: Time.now
          redirect_to root_path and return
        end
      else
        if @client.update client_params
          session[:client_id] = @client.id
          @client.update last_logged_at: Time.now
          redirect_to root_path and return
        end
      end
    end
  end

  def edit_account
    @client = current_client
    if request.patch?
      if current_client.is_a?(Client)
        current_client.update client_params
      else
        current_client.update company_client_params
      end
      if params[:client_password] && params[:client_password_2] & params[:client_password] == params[:client_password_2]
        current_client.update password: params[:client_password]
      end
    end
    render layout: 'welcome'
  end

  def login
    if request.post?
      client = current_franchise.clients.find_by_email(params[:email])
      company_client = current_franchise.company_clients.find_by_email(params[:email])
      if client && client.authenticate(params[:password])
        session[:client_id] = client.id
        client.update last_logged_at: Time.now
        target = session[:redirect_to] || root_path
        session[:redirect_to] = nil
        redirect_to target and return
      elsif company_client && company_client.authenticate(params[:password])
        session[:company_client_id] = company_client.id
        company_client.update last_logged_at: Time.now
        target = session[:redirect_to] || root_path
        session[:redirect_to] = nil
        redirect_to target and return
      else
        @error = 'INVALID_PASSWORD'
      end
    end
  rescue BCrypt::Errors::InvalidHash
    @error = 'INVALID_PASSWORD'
  end

  def admin
    if request.post?
      user = User.find_by_email(params[:email])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        user.update last_logged_at: Time.now
        target = session[:redirect_to] || clients_path
        session[:redirect_to] = nil
        redirect_to target and return
      end
    end
  end

  def admin_signup
    @user = find_user_by_private_key params[:key]
    return redirect_to root_path if @user.nil?
    if request.patch?
      if @user.update! user_params
        session[:user_id] = @user.id
        redirect_to clients_path and return
      end
    end
  end

  def logout
    session[:client_id] = nil
    session[:company_client_id] = nil
    session[:user_id] = nil
    redirect_to root_path
  end

  def gdpr_extract
    respond_to do |format|
      format.csv { send_data Client.where(id: current_client.id).to_csv, filename: 'donnees-personnelles.csv' }
    end
  end

  private

  def client_params
    params.require(:client).permit(:client_id, :first_name, :last_name, :male, :birth_date, { :objectives => [] }, :email, :phone, :email, :address, :zip_code, :city, :password, :password_2, :newsletter)
  end

  def company_client_params
    params.require(:company_client).permit(:first_name, :last_name, :male, :birth_date, { :objectives => [] }, :email, :phone, :email, :address, :zip_code, :city, :password, :password_2, :newsletter)
  end

  def user_params
    params.require(:user).permit(:password)
  end

  def find_user_by_private_key(key)
    x = nil
    current_franchise.users.each do |user|
      if key == user.private_key
        x = user
        break
      end
    end
    x
  end
end
