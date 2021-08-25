class CompaniesController < ApplicationController
  before_action :authenticate_admin
  before_action :get_companies, only: [:index, :create]
  before_action :find_company, only: [:show, :update, :destroy]

  def index
    @company = current_user.franchise.companies.new
    respond_to do |format|
      format.html
      format.csv { send_data @companies.to_csv, filename: 'clients-pro.csv' }
    end
  end

  def show
    @company_client = @company.company_clients.new
  end

  def create
    @company = Company.new company_params
    @company.franchise_id = current_user.franchise.id if @company.franchise_id.nil?
    if @company.save
      redirect_to companies_path
    else
      render :index, company: @company
    end
  end

  def update
    @company = current_user.franchise.companies.find params[:id]
    if @company.update company_params
      redirect_to @company
    else
      render :show, company: @company
    end
  end

  private

  def get_companies
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @companies = Franchise.find(params[:franchise_id]).companies
      else
        @companies = Company.all
      end
    else
      @companies = current_user.franchise.companies
    end
  end

  def company_params
    params.require(:company).permit(:franchise_id, :name, :email, :phone, :address, :zip_code, :city, :siret, :comment)
  end

  def find_company
    if current_user.superuser
      @company = Company.find params[:id]
    else
      @company = current_user.franchise.companies.find(params[:id])
    end
  end
end
