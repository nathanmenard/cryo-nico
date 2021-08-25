class ClientsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_clients, only: [:index, :create, :show]
  before_action :find_client, only: [:show, :update, :destroy, :update_credits]

  def index
    @client = current_user.franchise.clients.new
    
    if params[:search].present?
      @clients = @clients.where('unaccent(first_name) ILIKE unaccent(:search) OR unaccent(last_name) ILIKE unaccent(:search)', { search: "%#{params[:search]}%" })
    end

    respond_to do |format|
      format.html
      format.csv { send_data @clients.to_csv, filename: 'clients.csv' }
    end
  end

  def show
    @products = Product.all.order(name: :asc)
  end

  def create
    @client = Client.new client_params
    @client.franchise_id = current_user.franchise.id if @client.franchise_id.nil?
    @client.user = current_user
    if @client.save
      if @client.redirect_to_reservations == 'true'
        redirect_to reservations_path(client_id: @client.id) and return
      end
      if @client.redirect_to_payments == 'true'
        redirect_to payments_path(client_id: @client.id, new_client: 'true') and return
      end
      redirect_to @client
    else
      render :index, client: @client
    end
  end

  def update
    if @client.update client_params
      redirect_to @client
    else
      render :show, client: @client
    end
  end

  def destroy
    @client.destroy
    head :no_content
  end

  def update_credits
    params[:credits].each do |product_id, credits_count|
      credits_count = credits_count.to_i
      product = Product.find(product_id)
      current_count = @client.credits.where(product: product).count

      if credits_count > current_count
        add_count = credits_count - current_count
        (add_count).times do |x|
          @client.credits.create!(product: product)
        end
      elsif current_count > credits_count
        remove_count = current_count - credits_count
        (remove_count).times do |x|
          @client.credits.where(product: product).first.destroy!
        end
      end
    end
    redirect_to @client
  end

  private

  def client_params
    params.require(:client).permit(:redirect_to_reservations, :redirect_to_payments, :franchise_id, :first_name, :last_name, :male, :birth_date, { :objectives => [] }, :email, :phone, :email, :address, :zip_code, :city, :comment, :newsletter)
  end

  def get_clients
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @clients = Client.all.where(franchise_id: params[:franchise_id])
      else
        @clients = Client.all
      end
    elsif current_user.nutritionist
      @clients = current_user.clients
    else
      @clients = current_user.franchise.clients
    end
    @clients = @clients.order(:last_name).order(first_name: :desc)
    @clients = @clients.includes(:franchise).paginate(page: params[:page], per_page: 30)
  end

  def find_client
    id = params[:client_id].present? ? params[:client_id] : params[:id]
    if current_user.superuser
      @client = Client.find(id)
    elsif current_user.nutritionist
      @client = current_user.clients.find(id)
    else
      @client = current_user.franchise.clients.find(id)
    end
  end
end
