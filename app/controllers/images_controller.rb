class ImagesController < ApplicationController
  before_action :authenticate_admin
  before_action :find_product

  def destroy
    @product.images.find(params[:id]).purge
    head :no_content
  end

  private

  def find_product
    if current_user.superuser
      @product = Product.find params[:product_id]
    else
      @product = current_user.franchise.products.find(params[:product_id])
    end
  end
end
