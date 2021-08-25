require 'rails_helper'

RSpec.describe Welcome::SubscriptionsController, type: :controller do
  let(:franchise)       { FactoryBot.create(:franchise, banking_secret_id: '1', banking_secret_key: '2') }
  let(:room)            { FactoryBot.create(:room, franchise: franchise) }
  let(:product)         { FactoryBot.create(:product, room: room) }
  let!(:subscription_plan)  { FactoryBot.create(:subscription_plan, product: product) }
  let!(:client)         { FactoryBot.create(:client, franchise: franchise) }

  describe 'GET :new' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :new, params: { subscription_plan_id: subscription_plan.id }
        expect(response).to redirect_to(login_path)
      end
      context 'when franchise has no banking keys' do
        it 'raises error' do
          room.franchise.update!(banking_secret_id: nil, banking_secret_key: nil)
          expect {
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            get :new, params: { subscription_plan_id: subscription_plan.id }
          }.to raise_error(RuntimeError, "Franchise #{franchise.name} has no banking keys")
        end
      end
    end
    context 'when missing subscription_plan_id' do
      it 'returns 404' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :new, params: { subscription_plan_id: '0' }
        expect(response.status).to eq(404)
      end
    end
    it 'assigns @subscription_plan' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      get :new, params: { subscription_plan_id: subscription_plan.id }
      expect(assigns(:subscription_plan)).to eq(subscription_plan)
    end
    it 'creates payment instance' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      get :new, params: { subscription_plan_id: subscription_plan.id }
      expect(Payment.all.count).to eq(1)
      expect(Payment.last.amount).to eq(subscription_plan.total*100)
      expect(Payment.last.client).to eq(client)
      expect(Payment.last.transaction_id).not_to be_nil
      expect(Payment.last.product_name).to eq("Abonnement #{subscription_plan.product.name}")
    end
  end
end
