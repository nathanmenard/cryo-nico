require 'rails_helper'

RSpec.describe SubscriptionPlansController, type: :controller do
  let(:current_user)  { FactoryBot.create(:user) }
  let(:room)          { FactoryBot.create(:room, franchise: current_user.franchise) }
  let(:product)       { FactoryBot.create(:product, room: room) }

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { product_id: product.id, subscription_plan: { session_count: '4', total: '110' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { product_id: product.id, subscription_plan: { session_count: 'ok', total: '110' } }
        }.not_to change(product.subscription_plans, :count)
      end
    end
    it 'creates subscription plan' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { product_id: product.id, subscription_plan: { session_count: '4', total: '110' } }
      }.to change(product.subscription_plans, :count).by(1)
      expect(product.subscription_plans.first.session_count).to eq(4)
      expect(product.subscription_plans.first.total).to eq(110)
    end
  end
end
