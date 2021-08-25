class ProductPricesController < ApplicationController
  before_action :authenticate_admin

  def create
    @product = Product.find params[:product_id]
    professionnal = request.params[:product_prices][0]['professionnal']
    if professionnal == '1'
      @product.product_prices.where(professionnal: true).destroy_all
    else
      @product.product_prices.where(professionnal: false).destroy_all
    end
    request.params[:product_prices].each do |product_price_params|
      @product_price = @product.product_prices.new product_price_params
      @product_price.save
    end
    redirect_to @product
  end
end
