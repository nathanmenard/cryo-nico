class SubscriptionsController < ApplicationController
  before_action :authenticate_admin, only: [:index, :create, :update, :destroy]
  before_action :authenticate_client, only: [:new]

  before_action :get_subscriptions, only: [:index, :create]
  before_action :find_subscription, only: [:update, :destroy]

  skip_before_action :verify_authenticity_token, only: [:create]

  def index
    @subscription = Subscription.new
  end

  def new
    if current_franchise.banking_secret_id.blank? || current_franchise.banking_secret_key.blank?
      raise "Franchise #{current_franchise.name} has no banking keys"
    end
    @subscription_plan = current_franchise.subscription_plans.find(params[:subscription_plan_id])
    return head :not_found if @subscription_plan.nil?
    generate_banking_form
    render layout: false
  end


  def create
    @subscription = Subscription.new subscription_params
    @subscription.status = 'active'
    subscription_plan = SubscriptionPlan.find_or_create_by(product_id: @subscription.product_id, session_count: @subscription.session_count, total: @subscription.total)
    @subscription.subscription_plan = subscription_plan
    if @subscription.save
      redirect_to subscriptions_path
    else
      render :index, subscription: @subscription
    end
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to subscriptions_path
    else
      render status: 400, json: @subscription.errors.first
    end
  end

  def destroy
    to_be_canceled_at = (Date.today + 1.month).end_of_month
    if @subscription.update(status: 'canceled_by_admin', to_be_canceled_at: to_be_canceled_at)
      redirect_to subscriptions_path
    else
      render status: 400, json: @subscription.errors.first
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:status, :subscription_plan_id, :client_id, :external_id, :session_count, :total, :product_id)
  end

  def get_subscriptions
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @subscriptions = Franchise.find(params[:franchise_id]).subscriptions
      else
        @subscriptions = Subscription.all
      end
    else
      @subscriptions = current_user.franchise.subscriptions
    end
  end

  def find_subscription
    if current_user.superuser
      @subscription = Subscription.find(params[:id])
    else
      @subscription = current_user.franchise.subscriptions.find(params[:id])
    end
  end
end
