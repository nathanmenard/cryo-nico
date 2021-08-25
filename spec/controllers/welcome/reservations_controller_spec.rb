require 'rails_helper'

RSpec.describe Welcome::ReservationsController, type: :controller do
  let(:room)            {  FactoryBot.create(:room) }
  let(:product)         { FactoryBot.create(:product, room: room) }
  let!(:product_price)  { FactoryBot.create(:product_price, product: product) }
  let!(:client)         { FactoryBot.create(:client, franchise: room.franchise) }
  let!(:reservation)    { FactoryBot.create(:reservation, client: client, product_price: product_price) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{room.franchise.slug}.lvh.me"
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
    it 'assigns @reservations with reservations not canceled' do
      reservation_2 = FactoryBot.create(:reservation, client: client, canceled: true)
      request.host = "#{room.franchise.slug}.lvh.me"
      session[:client_id] = client.id
      get :index
      expect(assigns(:reservations)).to eq([reservation])
    end
  end

  describe 'PUT :update' do
    context 'when not logged in' do
      it' redirects to login form' do
        request.host = "#{room.franchise.slug}.lvh.me"
        put :update, params: { id: reservation.id, reservation: { to_be_paid_online: 'true' } }
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when reservation does not belong to current client' do
      let(:client_2) { FactoryBot.create(:client) }
      it' redirects to login form' do
        request.host = "#{room.franchise.slug}.lvh.me"
        session[:client_id] = client_2.id
        put :update, params: { id: reservation.id, reservation: { to_be_paid_online: 'true' } }
        expect(response).to redirect_to(login_path)
      end
    end
    it 'updates "to_be_paid_online"' do
      request.host = "#{room.franchise.slug}.lvh.me"
      session[:client_id] = client.id
      put :update, params: { id: reservation.id, reservation: { to_be_paid_online: 'true' } }
      expect(reservation.reload.to_be_paid_online).to eq(true)
    end
    it 'returns 204' do
      request.host = "#{room.franchise.slug}.lvh.me"
      session[:client_id] = client.id
      put :update, params: { id: reservation.id, reservation: { to_be_paid_online: 'true' } }
      expect(response.status).to eq(204)
    end
  end
end
