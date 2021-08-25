class CouponsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_coupons, only: [:index, :create]
  before_action :find_coupon, only: [:show, :update, :destroy]

  def index
    @coupon = current_user.franchise.coupons.new(usage_limit: 1, usage_limit_per_person: 1)
  end

  def show
    if current_user.superuser
      @products = Product.all
    else
      @products = current_user.franchise.products
    end
  end

  def create
    @coupon = Coupon.new coupon_params
    if @coupon.franchises.empty?  && !current_user.superuser
      @coupon.franchises = [current_user.franchise]
    end
    if @coupon.save
      redirect_to @coupon
    else
      render :index, coupon: @coupon
    end
  end

  def update
    if @coupon.update coupon_params
      redirect_to @coupon
    else
      render :show, coupon: @coupon
    end
  end

  def destroy
    @coupon.destroy
    head :no_content
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :value, :code, :percentage, :start_date, :end_date, :usage_limit, :usage_limit_per_person, { :franchise_ids => [] }, :male, { :objectives => [] }, { :product_ids => [] }, :new_client)
  end

  def get_coupons
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        coupons = Franchise.find(params[:franchise_id]).coupons
      else
        coupons = Coupon.all
      end
    else
      coupons = current_user.franchise.coupons
    end
    @coupons = coupons.active + coupons.expired
  end

  def find_coupon
    if current_user.superuser
      @coupon = Coupon.find(params[:id])
    else
      @coupon = current_user.franchise.coupons.find(params[:id])
    end
  end
end
