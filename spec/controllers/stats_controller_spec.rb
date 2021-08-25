require 'rails_helper'

RSpec.describe StatsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }

  describe 'GET :index' do
    let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
    let(:payment_1) { FactoryBot.create(:payment, :successful, amount: 3000, client: client, product_name: product.name) }
    let(:payment_2) { FactoryBot.create(:payment, :successful, amount: 5000, client: client, product_name: product.name) }
    let!(:reservation_1) { FactoryBot.create(:reservation, client: client, start_time: Date.today, product_price: product_price, payment: payment_1) }
    let!(:reservation_2) { FactoryBot.create(:reservation, client: client, start_time: Date.today, product_price: product_price, payment: payment_2) }

    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to('/admin')
      end
    end
    context 'nutritionist' do
      it 'redirects to clients path' do
        current_user.update(nutritionist: true)
        session[:user_id] = current_user.id
        get :index
        expect(response).to redirect_to(clients_path)
      end
    end
    it 'assigns @average_payments_amount' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:average_payments_amount)).to eq({
        product.id => 40,
      })
    end
    it 'assigns @revenue' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:revenue)).to eq({
        product.id => 24+40, # sum of HT payments
      })
    end
    it 'assigns @reservations_count' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:reservations_count)).to eq({
        product.id => 2,
      })
    end
    it 'assigns @average_session_count_per_client' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:average_session_count_per_client)).to eq({
        product.id => 2,
      })
    end
  end
end
