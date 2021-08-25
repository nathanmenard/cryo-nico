class TicketDistributionsController < ApplicationController
  layout 'welcome'

  before_action :authenticate_client

  def index
    if !current_client.is_a?(CompanyClient)
      redirect_to root_path and return
    end
    @credits = current_client.credits
  end

  def new
    if !current_client.is_a?(CompanyClient)
      redirect_to root_path and return
    end
    @product = current_franchise.products.find(params[:product_id])
    if current_client.credits.where(product: @product).empty?
      redirect_to product_path(id: @product.slug) and return
    end
    @company_clients = current_franchise.company_clients.where(company_client: current_client)
  end

  def create
    product = current_franchise.products.find(params[:product_id])
    if current_client.credits.where(product: product).empty?
      redirect_to product_path(id: product.slug) and return
    end
    if params[:quantity].blank?
      redirect_to new_ticket_distribution_path(product_id: product.id) and return
    end
    if params[:quantity].to_i > current_client.credits.where(product: product).count
      redirect_to new_ticket_distribution_path(product_id: product.id) and return
    end
    if company_client = current_client.company.company_clients.find_by(id: params[:company_client_id])
      ((params[:quantity]).to_i).times do
        company_client.credits.create!(
          product: product
        )
      end
    else
      company_client = current_client.company.company_clients.create!(
        email: params[:email],
        first_name: params[:first_name],
        last_name: params[:last_name],
        company_client: current_client,
      )
      ((params[:quantity]).to_i).times do
        company_client.credits.create!(
          product: product
        )
      end
    end
    ((params[:quantity]).to_i).times do
      current_client.credits.where(product: product).first.destroy
    end
    CompanyClientMailer.new_credit(company_client).deliver_later
    redirect_to ticket_distributions_path
  end
end
