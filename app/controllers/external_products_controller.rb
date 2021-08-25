class ExternalProductsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_external_products, only: [:index, :create]
  before_action :find_external_product, only: [:show, :update, :destroy]

  def index
    @external_product = current_user.franchise.external_products.new
  end

  def create
    @external_product = ExternalProduct.new external_product_params
    @external_product.franchise_id = current_user.franchise.id if @external_product.franchise_id.nil?
    if @external_product.save
      redirect_to external_products_path
    else
      render :index, external_product: @external_product
    end
  end

  def update
    if @external_product.update external_product_params
      redirect_to @external_product
    else
      render :index, external_product: @external_product
    end
  end

  def destroy
    @external_product.destroy
    head :no_content
  end

  private

  def external_product_params
    params.require(:external_product).permit(:name, :amount, :tax_rate, :franchise_id)
  end

  def get_external_products
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @external_products = ExternalProduct.all.where(franchise_id: params[:franchise_id])
      else
        @external_products = ExternalProduct.all
      end
    else
      @external_products = current_user.franchise.external_products
    end
  end

  def find_external_product
    if current_user.superuser
      @external_product = ExternalProduct.find params[:id]
    else
      @external_product = current_user.franchise.external_products.find(params[:id])
    end
  end
end
