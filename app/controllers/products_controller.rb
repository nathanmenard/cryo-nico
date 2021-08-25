class ProductsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_products, only: [:index, :create]
  before_action :find_product, only: [:show, :update, :destroy, :purge_image]

  def index
    @product = current_user.franchise.products.new
    if current_user.superuser
      @rooms = Room.all
    else
      @rooms = current_user.franchise.rooms
    end
  end

  def show
    @product_price = @product.product_prices.new
    if current_user.superuser
      @rooms = Room.all
    else
      @rooms = current_user.franchise.rooms
    end
  end

  def create
    @product = current_user.franchise.products.new product_params
    if @product.save
      redirect_to products_path
    else
      render :index, product: @product
    end
  end

  def update
    @product.thumbnail.purge if params[:product][:purge_thumbnail] == '1'
    if @product.update product_params
      redirect_to @product
    else
      render :show, product: @product
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

  def product_params
    params.require(:product).permit(:active, :room_id, :name, :description, :duration, :disclaimer, :thumbnail, :purge_thumbnail, :purge_disclaimer, images: [])
  end

  def get_products
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @products = Franchise.find(params[:franchise_id]).products
      else
        @products = Product.all
      end
    else
      @products = current_user.franchise.products
    end
  end

  def find_product
    if current_user.superuser
      @product = Product.find params[:id]
    else
      @product = current_user.franchise.products.find(params[:id])
    end
  end
end
