require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:client_2) { FactoryBot.create(:client) }
  let(:franchise_2) { FactoryBot.create(:franchise) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to('/admin')
      end
    end
    context 'superuser' do
      context 'when filter by franchise' do
        it 'returns all client from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: client_2.franchise }
          expect(assigns(:clients)).to eq([client_2])
        end
      end
      it 'returns all clients' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:clients).pluck(:id)).to eq(Client.all.pluck(:id))
      end
    end
    context 'nutritionist' do
      let!(:my_client) { FactoryBot.create(:client, user: current_user) }
      let!(:not_my_client) { FactoryBot.create(:client) }
      it 'returns all clients from given nutritionist' do
        current_user.update(nutritionist: true)
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:clients)).to eq([my_client])
      end
    end
    context 'when search params' do
      let!(:client_1) { FactoryBot.create(:client, franchise: current_user.franchise, first_name: 'Saïd', last_name: 'Mimouni') }
      let!(:client_2) { FactoryBot.create(:client, franchise: current_user.franchise, first_name: 'John', last_name: 'Test-Abc') }
      it 'returns matching clients' do
        session[:user_id] = current_user.id

        get :index, params: { search: 'said' }
        expect(assigns(:clients)).to eq([client_1])

        get :index, params: { search: 'test' }
        expect(assigns(:clients)).to eq([client_2])
      end
    end
    it 'returns all clients of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:clients)).to eq(current_user.franchise.clients)
    end
  end

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { client: { first_name: 'john', last_name: 'doe', male: 'true', birth_date: '03/08/1993' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { client: { first_name: nil } }
        }.not_to change(current_user.franchise.clients, :count)
      end
    end
    context 'when superuser' do
      it 'creates client for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { client: { franchise_id: franchise_2.id, first_name: 'john', last_name: 'doe', male: 'true', birth_date: '03/08/1993', email: 'client@gmail.com' } }
        }.to change(franchise_2.clients, :count).by(1)
        expect(Client.last.first_name).to eq('john')
        expect(Client.last.last_name).to eq('doe')
        expect(Client.last.male).to eq(true)
        expect(Client.last.birth_date.strftime('%d/%m/%Y')).to eq('03/08/1993')
        expect(Client.last.email).to eq('client@gmail.com')
      end
    end
    it 'creates client' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { client: { first_name: 'john', last_name: 'doe', male: 'true', birth_date: '03/08/1993', email: 'client@gmail.com' } }
      }.to change(current_user.franchise.clients, :count).by(1)
      expect(Client.last.first_name).to eq('john')
      expect(Client.last.last_name).to eq('doe')
      expect(Client.last.male).to eq(true)
      expect(Client.last.birth_date.strftime('%d/%m/%Y')).to eq('03/08/1993')
      expect(Client.last.email).to eq('client@gmail.com')
      expect(Client.last.user).to eq(current_user)
    end
    context 'when client.redirect_to_reservations' do
      it 'redirects to reservations' do
        session[:user_id] = current_user.id
        post :create, params: { client: { first_name: 'john', last_name: 'doe', male: 'true', birth_date: '03/08/1993', email: 'client@gmail.com', redirect_to_reservations: 'true', redirect_to_payments: '' } }
        expect(response).to redirect_to(reservations_path(client_id: Client.last.id))
      end
    end
    context 'when client.redirect_to_payments' do
      it 'redirects to payments' do
        session[:user_id] = current_user.id
        post :create, params: { client: { first_name: 'john', last_name: 'doe', male: 'true', birth_date: '03/08/1993', email: 'client@gmail.com', redirect_to_reservations: '', redirect_to_payments: 'true' } }
        expect(response).to redirect_to(payments_path(client_id: Client.last.id, new_client: 'true'))
      end
    end
  end

  describe 'PUT :update' do
    let!(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: client.id, client: { first_name: 'adam' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: client.id, client: { first_name: 'adam' } }
        }.not_to change(current_user.franchise.clients, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: client.id, client: { franchise_id: franchise_2.id, first_name: 'adam' } }
        }.to change(current_user.franchise.clients, :count).by(-1)
        expect(client.reload.franchise).to eq(franchise_2)
        expect(client.reload.first_name).to eq('adam')
      end
    end
    it 'updates client' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: client.id, client: { first_name: 'adam' } }
      }.not_to change(current_user.franchise.clients, :count)
      expect(client.reload.first_name).to eq('adam')
    end
  end

  describe 'GET :show' do
    let!(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
    let!(:client_2) { FactoryBot.create(:client) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: client.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        get :show, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when superuser' do
      context 'when client from another franchise' do
        it 'renders client page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: client_2.id }
          expect(assigns(:client)).to eq(client_2)
        end
      end
    end
    context 'nutritionist' do
      context 'when client from another user' do
        it 'displays 404' do
          current_user.update(nutritionist: true)
          session[:user_id] = current_user.id
          get :show, params: { id: client.id }
          expect(response.status).to eq(404)
        end
      end
    end
    it 'renders client page' do
      session[:user_id] = current_user.id
      get :show, params: { id: client.id }
      expect(assigns(:client)).to eq(client)
      expect(assigns(:products).pluck(:id)).to eq(Product.all.pluck(:id))
    end
  end

  describe 'PUT :update_credits' do
    let!(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
    let!(:client_2) { FactoryBot.create(:client) }
    let(:room) { FactoryBot.create(:room, franchise: client.franchise) }
    let!(:product_1) { FactoryBot.create(:product, room: room) }
    let!(:product_2) { FactoryBot.create(:product, room: room) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update_credits, params: { client_id: client.id }
        credits = {
          [product_1.id] => '3',
          [product_2.id] => '5',
        }
        put :update_credits, params: { client_id: client.id, credits: credits }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        credits = {
          [product_1.id] => '3',
          [product_2.id] => '5',
        }
        put :update_credits, params: { client_id: '0', credits: credits }
        expect(response.status).to eq(404)
      end
    end
    context 'when superuser' do
      context 'when client from another franchise' do
        it 'updates client credits' do
          current_user.update(superuser: true)
          session[:user_id] = current_user.id
          credits = {
            [product_1.id] => '2',
            [product_2.id] => '4',
          }
          put :update_credits, params: { client_id: client_2.id, credits: credits }
          expect(client_2.credits.where(product: product_1).count).to eq(2)
          expect(client_2.credits.where(product: product_2).count).to eq(4)
        end
      end
    end
    it 'updates client credits' do
      10.times { FactoryBot.create(:credit, product: product_2, client: client) }
      session[:user_id] = current_user.id
      credits = {
        [product_1.id] => '3',
        [product_2.id] => '5',
      }
      put :update_credits, params: { client_id: client.id, credits: credits }
      expect(client.credits.where(product: product_1).count).to eq(3)
      expect(client.credits.where(product: product_2).count).to eq(5)
    end
    it 'redirects to @client' do
      session[:user_id] = current_user.id
      credits = {
        [product_1.id] => '3',
        [product_2.id] => '5',
      }
      put :update_credits, params: { client_id: client.id, credits: credits }
      expect(response).to redirect_to(client)
    end
  end
end
