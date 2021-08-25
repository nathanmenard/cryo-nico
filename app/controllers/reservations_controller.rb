class ReservationsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_reservations, only: [:index, :create]
  before_action :find_reservation, only: [:update, :update_payment, :sign, :certificate]

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @blockers = current_user.franchise.blockers.where(start_time: @date.beginning_of_day..@date.end_of_day)
    @reservations = current_user.franchise.reservations.scheduled.where(start_time: @date.beginning_of_day..@date.end_of_day)
    if current_user.nutritionist
      @products = [current_user.franchise.products.has_unit_price.find_by(name: 'Nutrition')]
      @rooms = [@products.first.room]
    else
      @rooms = current_user.franchise.rooms.has_active_products
      @products = current_user.franchise.products.has_unit_price
    end
    @reservation = Reservation.new
    @client = current_user.franchise.clients.new
    @blocker = current_user.franchise.blockers.new
  end

  def create
    @reservation = current_user.franchise.reservations.new(reservation_params)
    @reservation.user = current_user
    @reservation.product_price = Product.find(@reservation.product_id).product_prices.find_by(professionnal: false, session_count: 1)
    @reservation.to_be_paid_online = false
    @reservation.generate_amount
    if @reservation.save
      credits = @reservation.client.credits.where(product: @reservation.product_price.product)
      if credits.any?
        credits.first.destroy
      else
        payment = Payment.create!(
          amount: @reservation.generate_amount,
          client: @reservation.client,
          product_name: @reservation.product_price.product.name,
        )
        @reservation.update!(payment: payment)
      end
      ClientMailer.new_reservation(@reservation).deliver_later if @reservation.email_notification
      if @reservation.start_time.today?
        redirect_to reservations_path and return
        return
      end
      redirect_to reservations_path(view: '3-days')
    else
      error = @reservation.errors.full_messages.first || 'INVALID_CAPACITY'
      render json: { error: error }, status: :bad_request
    end
  end

  def update
    if @reservation.update!(reservation_params)
      if @reservation.cancelation_reason.present?
        @reservation.update!(canceled: true)
        @reservation.refund(@reservation.perform_refund) if @reservation.perform_refund != 'false'
      end
      if @reservation.start_time.today?
        redirect_to reservations_path and return
        return
      end
      redirect_to reservations_path(view: '3-days')
    else
      render :index, reservation: @reservation
    end
  end

  def sign
    raise ActiveRecord::RecordNotFound if @reservation.first_time == false
    if request.post? && params[:signature]
      @reservation.update!(
        signature: params[:signature]
      )
      redirect_to reservations_path and return
    end
    render layout: false
  end

  private

  def reservation_params
    params.require(:reservation).permit(:client_id, :company_client_id, :product_id, :product_price_id, :start_time, :email_notification, :as_paid, :cancelation_reason, :perform_refund, :notes)
  end

  def get_reservations
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @reservations = Franchise.find(params[:franchise_id]).reservations
        @products = Franchise.find(params[:franchise_id]).products
      else
        @reservations = current_user.franchise.reservations
        @products = current_user.franchise.products
      end
    else
      @reservations = current_user.franchise.reservations
      @products = current_user.franchise.products
    end
    if params[:date]
      @reservations = @reservations.where('DATE(start_time) = ?', params[:date])
    end
    @products = @products.has_unit_price
  end

  def find_reservation
    if current_user.superuser
      @reservation = Reservation.find params[:id]
    else
      @reservation = current_user.franchise.reservations.find(params[:id])
    end
  end
end
