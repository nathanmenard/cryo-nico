require 'rails_helper'

RSpec.describe ProductPricesController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
  let(:product) { FactoryBot.create(:product, room: room) }

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { product_id: product.id, product_prices: [{ session_count: '1', total: '3000' }, { session_count: '2', total: '5000' }] }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
        post :create, params: { product_id: product.id, product_prices: [{ session_count: '1' }, { total: '5000' }] }
        }.not_to change(product.product_prices, :count)
      end
    end
    it 'removes existing product prices' do
      product_price = FactoryBot.create(:product_price, product: product)
      session[:user_id] = current_user.id
      post :create, params: { product_id: product.id, product_prices: [{ professionnal: 'false', session_count: '1', total: '30' }, { professionnal: 'false', session_count: '2', total: '50' }] }
      expect(product.product_prices.reload.count).to eq(2)
      expect(product.product_prices.pluck(:id)).not_to include(product_price.id)
    end
    it 'creates product price' do
      session[:user_id] = current_user.id
      post :create, params: { product_id: product.id, product_prices: [{ professionnal: 'false', session_count: '1', total: '30' }, { professionnal: 'false', session_count: '1', total: '20', first_time: 'true' }, { professionnal: 'false', session_count: '2', total: '50' }] }
      expect(product.product_prices.count).to eq(3)
      product_ids = ProductPrice.pluck(:product_id)
      expect(product_ids).to eq([product.id, product.id, product.id])
      professionnals = ProductPrice.pluck(:professionnal)
      expect(professionnals).to eq([false, false, false])
      totals = ProductPrice.all.map(&:total)
      expect(totals).to eq([30, 20, 50])
      session_counts = ProductPrice.pluck(:session_count)
      expect(session_counts).to eq([1, 1, 2])
      first_times = ProductPrice.pluck(:first_time)
      expect(first_times).to eq([false, true, false])
    end
  end
end
