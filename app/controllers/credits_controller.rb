class CreditsController < ApplicationController
  layout 'welcome'

  before_action :authenticate_client
  before_action :get_credits, only: [:index]
  before_action :find_credit, only: [:destroy]
  before_action :find_reservation, only: [:destroy]

  def index
  end

  def destroy
    if session[:cart].nil? || session[:cart].empty?
      redirect_to root_path and return
    end
    @credit.destroy
    @reservation.update!(paid_by_credit: true)
    session[:cart] = nil
    redirect_to @reservation
  end

  private

  def get_credits
    @credits = current_client.credits
  end

  def find_credit
    @credit = current_client.credits.find(params[:id])
  end

  def find_reservation
    @reservation = current_client.reservations.find(params[:credit][:reservation_id])
  end
end
