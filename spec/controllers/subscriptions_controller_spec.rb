require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let!(:current_user) { FactoryBot.create(:user) }

  describe 'GET :index' do
    let!(:client_2) { FactoryBot.create(:client) }
    let!(:subscription_2) { FactoryBot.create(:subscription, client: client_2) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to(admin_path)
      end
    end
    context 'superuser' do
      context 'when filter by franchise' do
        it 'returns all subscriptions from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: client_2.franchise_id }
          expect(assigns(:subscriptions)).to eq([subscription_2])
        end
      end
      it 'returns all subscriptions' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:subscriptions)).to eq(Subscription.all)
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
    it 'returns all subscriptions of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:subscriptions)).to eq(current_user.franchise.subscriptions)
    end
  end

  describe 'POST :create' do
    let!(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
    let!(:client_2) { FactoryBot.create(:client) }
    let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let!(:subscription_plan) { FactoryBot.create(:subscription_plan, product: product) }
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { subscription: { client_id: client.id, session_count: '4', total: '110', product_id: product.id } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      xit 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { subscription: { client_id: client.id, session_count: '4', total: '110', product_id: product.id } }
        }.not_to change(current_user.franchise.subscriptions, :count)
      end
    end
    context 'when superuser' do
      xit 'creates subscription for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { subscription: { client_id: client_2.id, session_count: '5', total: '110', product_id: product.id } }
        }.to change(client_2.franchise.subscriptions, :count).by(1)
        expect(Subscription.last.client).to eq(client_2)
        expect(Subscription.last.status).to eq('active')
        expect(Subscription.last.subscription_plan.session_count).to eq(5)
        expect(Subscription.last.subscription_plan.total).to eq(110)
        expect(Subscription.last.subscription_plan.product.room.franchise).to eq(client_2.franchise)
        expect(Subscription.last.subscription_plan.product).to eq(product)
      end
    end
    context 'when subscription plan does not exist' do
      it 'creates subscription plan' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { subscription: { client_id: client.id, session_count: '5', total: '110', product_id: product.id } }
        }.to change(current_user.franchise.subscription_plans, :count).by(1)
        expect(SubscriptionPlan.last.session_count).to eq(5)
        expect(SubscriptionPlan.last.total).to eq(110)
        expect(SubscriptionPlan.last.product).to eq(product)
      end
    end
    context 'when subscription already exists' do
      it 'does not create subscription plan' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { subscription: { client_id: client.id, session_count: '4', total: '110', product_id: product.id } }
        }.not_to change(current_user.franchise.subscription_plans, :count)
      end
    end
    it 'creates subscription' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { subscription: { client_id: client.id, session_count: '4', total: '110', product_id: product.id } }
      }.to change(current_user.franchise.subscriptions, :count).by(1)
      expect(Subscription.last.client).to eq(client)
      expect(Subscription.last.subscription_plan).to eq(subscription_plan)
      expect(Subscription.last.status).to eq('active')
    end
  end

  describe 'PATCH :update' do
    let(:user_2)        { FactoryBot.create(:user) }
    let(:client)        { FactoryBot.create(:client, franchise: current_user.franchise) }
    let!(:subscription) { FactoryBot.create(:subscription, client: client) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: subscription.id, subscription: { status: 'canceled_by_admin' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when superuser' do
      it 'updates subscription' do
        user_2.update(superuser: true)
        session[:user_id] = user_2.id
        put :update, params: { id: subscription.id, subscription: { status: 'canceled_by_admin' } }
        expect(subscription.reload.status).to eq('canceled_by_admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: subscription.id, subscription: { status: '' } }
        }.not_to change(subscription.reload, :status)
      end
    end
    it 'updates subscription' do
      session[:user_id] = current_user.id
      put :update, params: { id: subscription.id, subscription: { status: 'canceled_by_admin' } }
      expect(subscription.reload.status).to eq('canceled_by_admin')
    end
  end

  describe 'DELETE :destroy' do
    let(:user_2)        { FactoryBot.create(:user) }
    let(:client)        { FactoryBot.create(:client, franchise: current_user.franchise) }
    let!(:subscription) { FactoryBot.create(:subscription, client: client) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: subscription.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when superuser' do
      it 'updates subscription' do
        user_2.update(superuser: true)
        session[:user_id] = user_2.id
        delete :destroy, params: { id: subscription.id }
        expect(subscription.reload.status).to eq('canceled_by_admin')
      end
    end
    it 'updates subscription' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: subscription.id }
      expect(subscription.reload.status).to eq('canceled_by_admin')
      expect(subscription.reload.to_be_canceled_at).to eq(((Date.today+1.month).end_of_month).to_time)
    end
  end
end
