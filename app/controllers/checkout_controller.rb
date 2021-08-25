class CheckoutController < ApplicationController
  include ActionView::Helpers::NumberHelper
  layout 'welcome'

  before_action :authenticate_client, only: [:new]
  skip_before_action :verify_authenticity_token, only: [:callback]

  def new
    if current_franchise.banking_secret_id.blank? || current_franchise.banking_secret_key.blank?
      raise "Franchise #{current_franchise.name} has no banking keys"
    end
    if session[:cart].nil? || session[:cart].empty?
      redirect_to root_path and return
    end
    @product_price = current_franchise.product_prices.find session[:cart][0]['product_price_id']
    if request.post? && params[:id] && params[:coupon]
      @reservation = current_franchise.reservations.find params[:id]
      payment = @reservation.payment
      coupon = current_franchise.coupons.find_by(code: params[:coupon].downcase)
      if coupon
        payment.update(coupon: coupon)
      else
        payment.update(coupon: nil)
      end
    elsif request.get? && params[:id] && params[:coupon] == 'nil'
      @reservation = current_franchise.reservations.find(params[:id])
      @reservation.payment.update!(coupon: nil)
    else
      last_reservation = current_client.reservations.last
      if last_reservation && last_reservation.product_price == @product_price && !last_reservation.paid? && last_reservation.start_time.present?
        @reservation = last_reservation
      else
        reservation_params = {
          product_price: @product_price,
          email_notification: true,
          first_time: true,
          start_time: session[:cart][0]['start_time'],
          to_be_paid_online: true,
        }
        if current_client.is_a?(CompanyClient)
          reservation_params[:company_client] = current_client
        else
          reservation_params[:client] = current_client
        end
        @reservation = current_franchise.reservations.new reservation_params
        @reservation.save!
        payment = Payment.create!(
          client: @reservation.client,
          company_client: @reservation.company_client,
          amount: @reservation.generate_amount,
          product_name: @reservation.product_price.product.name,
          mode: 'online',
        )
        @reservation.update!(payment: payment)
      end
      amount = (@reservation.product_price.total*100).to_i
    end
    @amount = @reservation.payment.amount
    if @reservation.payment.coupon
      @amount -= @reservation.payment.coupon.discount_amount(@reservation.payment)
    end
    generate_banking_form
  end

  def callback
    if session[:cart].nil? || session[:cart].empty?
      redirect_to checkout_path and return
    end
    product_price_id = session[:cart][0]['product_price_id']
    payment = Payment.find_by(transaction_id: params[:vads_trans_id])
    if payment.company_client.present?
      product_price = ProductPrice.find_by(id: product_price_id, professionnal: true)
      head :not_found and return if product_price.nil?
      if params[:vads_trans_status].in? ['AUTHORISED', 'ACCEPTED']
        (product_price.session_count).times do |x|
          current_client.credits.create!(product: product_price.product)
        end
        payment.update!(
          bank_name: params[:vads_bank_label]
        )
        # ClientMailer.invoice(reservation).deliver_later
        success = true
      else
        success = false
      end
    else
      payment = Payment.find_by(transaction_id: params[:vads_trans_id])
      reservation = payment.client.reservations.where(payment: payment).last
      if params[:vads_trans_status].in? ['AUTHORISED', 'ACCEPTED']
        if reservation.product_price.session_count > 1
          (reservation.product_price.session_count).times do |x|
            reservation.client.credits.create!(client: reservation.client, product: reservation.product_price.product)
          end
        end
        reservation.payment.update!(
          bank_name: params[:vads_bank_label]
        )
        ClientMailer.invoice(reservation).deliver_later
        success = true
      else
        success = false
      end
    end
    session[:cart] = nil
    if reservation.present?
      current_client = reservation.client || reservation.company_client
      current_client.reservations.where({
        product_price: reservation.product_price,
        payment: nil
      }).destroy_all
    end
    if success == true
      return render :thanks
    end
    render json: params
  end

  private

  def generate_banking_form
    @data = {
      vads_action_mode: 'INTERACTIVE',
      vads_amount: @amount,
      vads_ctx_mode:'TEST',
      vads_currency: '978',
      vads_page_action: 'PAYMENT',
      vads_payment_config: 'SINGLE',
      vads_redirect_error_message: 'Vous allez être redirigé vers votre site marchand',
      vads_redirect_error_timeout: '0',
      vads_redirect_success_message: 'Vous allez être redirige vers votre site marchand',
      vads_redirect_success_timeout: '0',
      vads_return_mode: 'GET',
      vads_site_id: current_franchise.banking_secret_id,
      vads_theme_config: 'SUCCESS_FOOTER_MSG_RETURN=Retourner sur votre compte',
      vads_trans_date: DateTime.now.strftime('%Y%m%d%H%m%S'),
      vads_trans_id: @reservation.payment.transaction_id,
      vads_url_return: "https://#{current_franchise.slug}.cryotera.xyz/checkout/notification",
      vads_version: 'V2',
    }
    data = @data.values.join('+')
    data += "+#{current_franchise.banking_secret_key}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), current_franchise.banking_secret_key, data)).strip()
    @data[:signature] = signature
  end
end
