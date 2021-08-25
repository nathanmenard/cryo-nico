class CompanyClientsController < ApplicationController
  before_action :authenticate_admin

  def create
    @company = Company.find params[:company_id]
    @company_client = @company.company_clients.new company_client_params
    if @company_client.save
      CompanyClientMailer.invite(@company_client).deliver_later
      redirect_to @company
    else
      render template: 'companies/show', company: @company, company_client: @company_client
    end
  end

  private

  def company_client_params
    params.require(:company_client).permit(:first_name, :last_name, :email, :job, :phone)
  end
end
