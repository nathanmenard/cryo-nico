class PaymentsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_payments, only: [:index]
  before_action :find_payment, only: [:update, :destroy]
  before_action :find_payment_by_date_id, only: [:show]

  def index
    @client = current_user.franchise.clients.build(redirect_to_payments: true)
    @date = params[:date].present? ? params[:date].to_date : Date.today
    @payment = Payment.new
    if params[:view] == 'month'
      first_of_month = @date.beginning_of_month
      last_of_month = @date.end_of_month
      @payments = @payments.where('payments.updated_at BETWEEN ? AND ?', first_of_month, last_of_month)
    elsif params[:view] == 'year'
      first_of_year = @date.beginning_of_year
      last_of_year = @date.end_of_year
      @payments = @payments.where('payments.updated_at BETWEEN ? AND ?', first_of_year, last_of_year)
    else
      @payments = @payments.where('DATE(payments.updated_at) = ?', params[:date] || Date.today)
    end
    @payments = @payments.successful.order(updated_at: :desc)
    respond_to do |format|
      format.html
      format.csv { send_data @payments.to_csv, filename: 'tickets.csv' }
    end
  end

  def show
    respond_to do |format|
      format.pdf do
        send_data(generate_pdf(@payment), :filename => "ticket-#{@payment.date_id}.pdf", :type => "application/pdf")
      end
    end
  end

  def create
    @payment = Payment.new payment_params
    if @payment.external_product_id.present?
      external_product = ExternalProduct.find(@payment.external_product_id)
      @payment.product_name = external_product.name
      @payment.amount = external_product.amount*100
      @payment.tax_rate = external_product.tax_rate
    elsif @payment.product_id.present?
      product = Product.find(@payment.product_id)
      session_count = @payment.session_count.to_f
      session_price = @payment.session_price.to_f
      @payment.product_name = "#{product.name} (#{session_count.to_i} séance#{session_count > 1 ? 's' : ''})"
      @payment.amount = session_count*session_price*100
      @payment.tax_rate = 20
    end
    @payment.as_paid = true
    if @payment.save
      if @payment.product_id.present?
        (@payment.session_count.to_i).times do
          @payment.client.credits.create!(
            product: Product.find(@payment.product_id),
          )
        end
      end
      if @payment.new_client
        ClientMailer.invite_by_admin(@payment.client).deliver_later
      end
      redirect_to payments_path
    else
      render :index, payment: @payment
    end
  end

  def update
    if @payment.update!(payment_params)
      as_paid_changes = @payment.previous_changes[:as_paid]
      as_paid_changed = as_paid_changes ? as_paid_changes.uniq.length > 1 : false
      if as_paid_changed && @payment.as_paid?
        ClientMailer.invoice(@payment).deliver_later
        redirect_to reservations_path and return
      end
    end
  end

  def destroy
    @payment.destroy
    head :no_content
  end

  private

  def generate_pdf(payment)
    client = payment.client ? payment.client : payment.company_client
    Prawn::Document.new do
      text "Ticket n° #{payment.date_id}", size: 20, style: :bold
      text " "
      text "Prestataire", style: :bold
      text "Cryotera #{client.franchise.name}"
      text client.franchise.address
      text "#{client.franchise.zip_code} #{client.franchise.city}"
      text "SIRET : #{client.franchise.siret}"
      text " "
      text "Date", style: :bold
      text I18n.l(payment.created_at, format: :long)
      text " "
      text "Client", style: :bold
      text client.full_name
      text " "
      text "Total HT", style: :bold
      text ActiveSupport::NumberHelper.number_to_currency(payment.amount_without_tax/100)
      text " "
      text "TVA #{payment.tax_rate}%", style: :bold
      text ActiveSupport::NumberHelper.number_to_currency(payment.tax_amount/100)
      text " "
      text "Total TTC", style: :bold
      text ActiveSupport::NumberHelper.number_to_currency(payment.amount/100)
      text " "
      text "Prestation", style: :bold
      text payment.product_name
      text " "
      text "Moyen de paiement", style: :bold
      text payment.mode_in_french
    end.render
  end

  def payment_params
    params.require(:payment).permit(:client_id, :new_client, :external_product_id, :product_id, :session_count, :session_price, :mode, :as_paid)
  end

  def get_payments
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @payments = Franchise.find(params[:franchise_id]).payments
      else
        @payments = Payment.all
      end
    else
      @payments = current_user.franchise.payments
    end
  end

  def find_payment
    if current_user.superuser
      @payment = Payment.find(params[:id])
    else
      @payment = current_user.franchise.payments.find(params[:id])
    end
  end

  def find_payment_by_date_id
    if current_user.superuser
      @payment = Payment.find_by_date_id(params[:id])
    else
      @payment = current_user.franchise.payments.find_by_date_id(params[:id])
    end
    head :not_found if @payment.nil?
  end
end
