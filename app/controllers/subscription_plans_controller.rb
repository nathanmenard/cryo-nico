class SubscriptionPlansController < ApplicationController
  before_action :authenticate_admin

  def create
    product = Product.find(params[:product_id])
    subscription_plan = product.subscription_plans.new(subscription_plan_params)
    subscription_plan.save
    redirect_to product
  end

  private

  def subscription_plan_params
    params.require(:subscription_plan).permit(:session_count, :total)
  end
end
