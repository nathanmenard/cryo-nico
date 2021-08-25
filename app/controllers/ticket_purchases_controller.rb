class TicketPurchasesController < ApplicationController
  include ActionView::Helpers::NumberHelper
  layout 'welcome'

  before_action :authenticate_client, only: [:new]
  skip_before_action :verify_authenticity_token, only: [:callback]

  def new
    if current_franchise.banking_secret_id.blank? || current_franchise.banking_secret_key.blank?
      raise "Franchise #{current_franchise.name} has no banking keys"
    end
    if !current_client.is_a?(CompanyClient)
      redirect_to root_path and return
    end
    @product_price = current_franchise.product_prices.find_by(id: params[:product_price_id], professionnal: true)
    head :not_found and return if @product_price.nil?
    session[:cart] = [{ 'product_price_id' => @product_price.id }]
    @payment = Payment.create!(
      company_client: current_client,
      amount: @product_price.total*100,
      product_name: @product_price.product.name,
      mode: 'online',
    )
    generate_banking_form
  end

  def callback
    if session[:cart].nil? || session[:cart].empty?
      redirect_to root_path and return
    end
    product_price_id = session[:cart][0]['product_price_id']
    payment = Payment.find_by(transaction_id: params[:vads_trans_id])
    product_price = ProductPrice.find_by(id: product_price_id, professionnal: true)
    head :not_found and return if product_price.nil?
    if params[:vads_trans_status].in? ['AUTHORISED', 'ACCEPTED']
      (product_price.session_count).times do |x|
        current_client.credits.create!(product: product_price.product)
      end
      payment.update!(
        bank_name: params[:vads_bank_label]
      )
      # ClientMailer.invoice(reservation).deliver_now
      session[:cart] = nil
      render json: { success: true }
    else
      render json: params
    end
  end

  private

  def generate_banking_form
    @data = {
      vads_action_mode: 'INTERACTIVE',
      vads_amount: @payment.amount,
      vads_ctx_mode:'TEST',
      vads_currency: '978',
      vads_page_action: 'PAYMENT',
      vads_payment_config: 'SINGLE',
      vads_return_mode: 'POST',
      vads_site_id: current_franchise.banking_secret_id,
      vads_trans_date: DateTime.now.strftime('%Y%m%d%H%m%S'),
      vads_trans_id: @payment.transaction_id,
      vads_version: 'V2',
    }
    data = @data.values.join('+')
    data += "+#{current_franchise.banking_secret_key}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), current_franchise.banking_secret_key, data)).strip()
    @data[:signature] = signature
  end
end
