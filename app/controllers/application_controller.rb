class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :authenticate_admin, only: :help

  def root
    @franchises = Franchise.all.order(:name)
    render layout: false
  end

  def current_franchise
    Franchise.all.each do |franchise|
      if request.subdomain.gsub(/www./, '') == franchise.slug
        return franchise
      end
    end
    return nil
  end

  def current_user
    user_id = session[:user_id]
    if user_id.nil?
      redirect_to admin_path
    else
      User.find(user_id)
    end
  end

  def current_client
    Client.find_by(id: session[:client_id]) || CompanyClient.find_by(id: session[:company_client_id])
  end

  def authenticate_client
    if session[:client_id].nil? && session[:company_client_id].nil?
      session[:redirect_to] = request.path
      redirect_to login_path and return
    end
  end

  def authenticate_admin
    if session[:user_id].nil?
      session[:redirect_to] = request.path
      redirect_to admin_path and return
    end
    if current_user.nutritionist? && (controller_name != 'clients' && controller_name != 'reservations' && controller_name != 'calendar_items')
      redirect_to clients_path and return
    end
  end

  def authenticate_superadmin
    if session[:user_id].nil?
      redirect_to admin_path
    else
      user = User.find(session[:user_id])
      redirect_to clients_path unless user.superuser?
    end
  end

  def authenticate_franchise
    if request.subdomain.blank? || request.subdomain == 'www'
      redirect_to root_path
    end
  end

  def record_not_found
    render file: "#{Rails.root}/public/404.html",  layout: false, status: :not_found
  end

  def help
    ActionMailer::Base.mail(
      from: 'contact@cryotera.fr',
      to: 'sayid.mimouni@gmail.com',
      subject: "Cryotera #{current_user.franchise.name} - Demande d'aide",
      body: params[:body]
    ).deliver
    redirect_back(fallback_location: clients_path)
  end

  helper_method :current_user, :current_franchise, :current_client
end
