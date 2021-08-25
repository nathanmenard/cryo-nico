class FranchisesController < ApplicationController
  before_action :authenticate_superadmin
  before_action :get_franchises, only: [:index, :create, :update]

  def index
    @franchise = Franchise.new
  end

  def show
    @franchise = Franchise.find params[:id]
  end

  def create
    @franchise = Franchise.new franchise_params
    if @franchise.save
      redirect_to @franchise
    else
      render :index, franchise: @franchise
    end
  end

  def update
    @franchise = Franchise.find params[:id]
    if @franchise.update franchise_params
      redirect_to @franchise
    else
      render :show
    end
  end

  def franchise_params
    params
      .require(:franchise)
      .permit(:name, :email, :instagram_username, :facebook_chat_snippet, :banking_provider, :banking_secret_id, :banking_secret_key, :address, :zip_code, :city, :siret, :tax_id, :iban, :phone, :sendinblue_api_key, business_hours_attributes: business_hours_attributes)
  end

  def business_hours_attributes
    [:id, :morning_start_time, :morning_end_time, :afternoon_start_time, :afternoon_end_time]
  end

  private

  def get_franchises
    @franchises = Franchise.all.order(:name)
  end
end
