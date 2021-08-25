class StatsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_stats, only: [:index]

  def index
    @date = params[:date].present? ? params[:date].to_date : Date.today
    @products = current_user.franchise.products
    @external_products = current_user.franchise.external_products

    @average_payments_amount = {}
    @products.each do |product|
      @average_payments_amount[product.id] = product.average_payments_amount
    end

    @revenue = {}
    @products.each do |product|
      @revenue[product.id] = Payment.by_product(product.name).successful.sum(:amount).to_i*0.8/100
    end

    @reservations_count = {}
    @products.each do |product|
      @reservations_count[product.id] = product.reservations.paid.count
    end

    @average_session_count_per_client = {}
    @products.each do |product|
      @average_session_count_per_client[product.id] = product.average_session_count_per_client
    end

    respond_to do |format|
      format.html
      format.csv { send_data @products.to_csv, filename: 'stats.csv' }
    end
  end

  private

  def get_stats
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
    end
  end
end
