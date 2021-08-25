class Welcome::SubscriptionsController < ApplicationController
  before_action :authenticate_client

  layout 'welcome'

  def new
    if current_franchise.banking_secret_id.blank? || current_franchise.banking_secret_key.blank?
      raise "Franchise #{current_franchise.name} has no banking keys"
    end
    @subscription_plan = current_franchise.subscription_plans.find(params[:subscription_plan_id])
    payment_params = {
      mode: 'online',
      amount: @subscription_plan.total*100,
      product_name: "Abonnement #{@subscription_plan.product.name}",
    }
    if current_client.is_a?(CompanyClient)
      payment_params[:company_client] = current_client
    else
      payment_params[:client] = current_client
    end
    @payment = Payment.create!(payment_params)
    generate_banking_form
  end

  def create
  end

  private

  def generate_banking_form
    @data = {
      vads_action_mode: 'INTERACTIVE',
      vads_amount: @payment.amount,
      vads_ctx_mode: 'TEST',
      vads_currency: '978',
      vads_page_action: 'REGISTER_PAY_SUBSCRIBE',
      vads_payment_config: 'SINGLE',
      vads_redirect_error_message: 'Vous allez être redirigé vers votre site marchand',
      vads_redirect_error_timeout: '0',
      vads_redirect_success_message: 'Vous allez être redirige vers votre site marchand',
      vads_redirect_success_timeout: '0',
      vads_return_mode: 'GET',
      vads_site_id: current_franchise.banking_secret_id,
      vads_theme_config: 'SUCCESS_FOOTER_MSG_RETURN=Retourner sur votre compte',
      vads_trans_date: DateTime.now.strftime('%Y%m%d%H%m%S'),
      vads_trans_id: @payment.transaction_id,
      vads_url_return: "https://#{current_franchise.slug}.cryotera.xyz/subscriptions",
      vads_version: 'V2',
    }
    data = @data.values.join('+')
    data += "+#{current_franchise.banking_secret_key}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), current_franchise.banking_secret_key, data)).strip()
    @data[:signature] = signature
  end
end
