class Welcome::ReservationsController < ApplicationController
  before_action :authenticate_client

  layout 'welcome'

  def index
    @reservations = current_client.reservations.scheduled.order(id: :desc)
  end

  def update
    reservation = current_client.reservations.find_by(id: params[:id])
    if reservation.nil?
      redirect_to login_path and return
    end
    reservation.update!(reservation_params)
    head :no_content
  end

  private

  def reservation_params
    params.require(:reservation).permit(:to_be_paid_online)
  end
end
