class WelcomeController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_client, only: [:product, :sponsorship, :edit_reservation, :cancel_reservation, :thanks]

  def home
    @products = current_franchise.products.includes([:thumbnail_attachment]).active
    render layout: false
  end

  def product
    @product = current_franchise.products.includes([:room]).find_by_slug(params[:slug])
    if @product.name == 'Nutrition'
      render :nutrition and return
    end
    if @product.ever_bought_by?(current_client)
      @product_price = @product.product_prices.find_by(professionnal: false, session_count: 1, first_time: false) 
    else
      @product_price = @product.product_prices.find_by(professionnal: false, session_count: 1, first_time: true) 
      unless @product_price
        @product_price = @product.product_prices.find_by(professionnal: false, session_count: 1, first_time: false) 
      end
    end
    @reservation = current_client.reservations.build({
      product_price: @product_price,
    })
    generate_mini_calendar
  end

  def cart
    render json: session[:cart]
  end

  def add_to_cart
    session[:cart] ||= []
    unless session[:cart].any? { |item| item[:product_price_id] == params[:product_price_id] }
      session[:cart][0] = { 
        product_price_id: params[:product_price_id],
        start_time: params[:start_time],
      }
    end
    head :no_content
  end

  def said
    reservation = Reservation.first
    pre_total = reservation.product_price.total
    tax_id = reservation.product_price.product.room.franchise.tax_id

    notes = []
    if tax_id.present?
      notes << "Numéro de TVA : #{tax_id}"
    end

    item = InvoicePrinter::Document::Item.new(
      name: reservation.product_price.product.name,
      quantity: reservation.product_price.session_count,
      price: number_to_currency(reservation.product_price.unit_price),
      amount: number_to_currency(pre_total),
    )
    invoice = InvoicePrinter::Document.new(
      number: "##{Reservation.first.id}",
      provider_name: "Cryotera #{current_franchise.name}",
      provider_tax_id: reservation.product_price.product.room.franchise.siret,
      provider_tax_id2: tax_id,
      provider_lines: "#{reservation.product_price.product.room.franchise.address}\r\n#{reservation.product_price.product.room.franchise.zip_code} #{reservation.product_price.product.room.franchise.city}",
      purchaser_name: reservation.client.full_name,
      purchaser_lines: "#{reservation.client.address}\r\n#{reservation.client.zip_code} #{reservation.client.city}",
      issue_date: l(reservation.created_at, format: :short),
      due_date: (reservation.created_at + 30.days).strftime('%d/%m/%Y'),
      subtotal: number_to_currency(pre_total),
      tax: number_to_currency(0),
      total: number_to_currency(pre_total),
      bank_account_number: reservation.product_price.product.room.franchise.iban,
      items: [item],
      note: notes.join,
    )
    labels = {
      name: 'Facture',
      provider: 'Prestataire',
      tax_id: 'SIRET',
      tax_id2: 'N° de TVA',
      purchaser: 'Client',
      issue_date: "Date d'émission",
      due_date: 'Date limite de paiement',
      total: 'Net à payer TTC',
      tax: 'TVA',
      item: 'Prestation',
      quantity: 'Quantité',
      price_per_item: 'Prix par séance',
      subtotal: 'Sous-total HT',
      amount: 'Total HT',
      account_number: 'IBAN',
      payment_by_transfer: 'Pour les paiements par virement :',
    }
    respond_to do |format|
      format.pdf {
        @pdf = InvoicePrinter.render(
          document: invoice,
          labels: labels
        )
        send_data @pdf, type: 'application/pdf', disposition: 'inline'
      }
    end
  end

  def contact
    if request.post?
      ActionMailer::Base.mail(
        from: "#{params[:first_name]} #{params[:last_name]} <contact@cryotera.fr>",
        to: current_franchise.email,
        reply_to: params[:email],
        subject: params[:subject],
        body: params[:message],
      ).deliver_later
      if params[:type] == 'Nutrition'
        nutritionist = current_franchise.users.find_by(nutritionist: true)
        if nutritionist
          ActionMailer::Base.mail(
            from: "#{params[:first_name]} #{params[:last_name]} <contact@cryotera.fr>",
            to: nutritionist.email,
            reply_to: params[:email],
            subject: params[:subject],
            body: params[:message],
          ).deliver_later
        end
      end
      @success = true
    end
  end

  def checkout_times
    reservation = current_franchise.reservations.find_by(id: params[:reservation_id])
    if params[:date]
      reservation.update(start_time: DateTime.parse(params[:date]))
    elsif params[:hour] && params[:minutes]
      time = "#{params[:hour]}:#{params[:minutes]}"
      reservation.start_time = "#{reservation.start_time.strftime('%Y-%m-%d')}T:#{time}+01:00"
    end
    reservation.save!
    render plain: l(reservation.reload.start_time, format: :short)
  end

  def sponsorship
    @clients = current_franchise.clients.where(client: current_client)
    if request.post? && params[:email].present?
      existing = Client.find_by(email: params[:email])
      ClientMailer.invite(current_client, params[:email]).deliver_later if !existing
      redirect_to sponsorship_path
    end
  end

  def edit_reservation
    @reservation = current_client.reservations.find(params[:id])
    generate_mini_calendar
  end

  def cancel_reservation
    reservation = current_client.reservations.find(params[:id])
    reservation.update!(cancelation_reason: 'canceled_by_client', canceled: true)
    reservation.refund
    head :no_content
  end

  def payments
    @payments = current_client.payments
  end

  def thanks
    render 'checkout/thanks'
  end

  private

  def generate_banking_form
    @data = {
      vads_action_mode: 'INTERACTIVE',
      vads_amount: @reservation.amount,
      vads_ctx_mode: 'TEST',
      vads_currency: '978',
      vads_page_action: 'PAYMENT',
      vads_payment_config: 'SINGLE',
      vads_return_mode: 'POST',
      vads_site_id: current_franchise.banking_secret_id,
      vads_trans_date: DateTime.now.strftime('%Y%m%d%H%m%S'),
      vads_trans_id: @reservation.transaction_id,
      vads_version: 'V2',
    }
    data = @data.values.join('+')
    data += "+#{current_franchise.banking_secret_key}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), current_franchise.banking_secret_key, data)).strip()
    @data[:signature] = signature
  end

  def generate_mini_calendar
    if params[:start_from]
      start_from = Date.parse(params[:start_from])
      if start_from < Date.today
        start_from = Date.tomorrow
      end
    else
      start_from = Date.tomorrow
    end
    if start_from.sunday?
      start_from = start_from + 1.day
    end
    @dates = [start_from]
    while @dates.length < 4
      day = (@dates.last)+1.day
      if day.sunday?
        @dates << day+1.day
      else
        @dates << day
      end
    end
  end
end
