require 'rails_helper'

RSpec.describe FranchisesController, type: :controller do
  let!(:current_user) { FactoryBot.create(:user) }

  describe 'GET /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to(admin_path)
      end
    end
    context 'when not superuser' do
      it 'redirects to clients path' do
        session[:user_id] = current_user.id
        get :index
        expect(response).to redirect_to(clients_path)
      end
    end
    it 'returns all franchises' do
      current_user.update superuser: true
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:franchises)).to eq(Franchise.all.order(:name))
    end
  end

  describe 'GET /:id' do
    let!(:franchise) { FactoryBot.create(:franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: franchise.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not superuser' do
      it 'redirects to clients path' do
        session[:user_id] = current_user.id
        get :show, params: { id: franchise.id }
        expect(response).to redirect_to(clients_path)
      end
    end
    context 'when not found' do
      it 'displays 404' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :show, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    it 'renders franchise page' do
      current_user.update superuser: true
      session[:user_id] = current_user.id
      get :show, params: { id: franchise.id }
      expect(assigns(:franchise)).to eq(franchise)
    end
  end

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { franchise: { name: 'Lyon' } }
        expect(response).to redirect_to(admin_path)
      end
    end
    context 'when not superuser' do
      it 'redirects to clients path' do
        session[:user_id] = current_user.id
        post :create, params: { franchise: { name: 'Lyon' } }
        expect(response).to redirect_to(clients_path)
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { franchise: { name: '' } }
        }.not_to change(Franchise, :count)
        expect(response).to render_template(:index)
      end
    end
    it 'creates franchise' do
      expect {
        current_user.update superuser: true
        session[:user_id] = current_user.id
        post :create, params: { franchise: { name: 'Marseille' } }
      }.to change(Franchise.all, :count).by(1)
      expect(Franchise.last.name).to eq('Marseille')
    end
  end

  describe 'PUT /:id' do
    let!(:franchise) { FactoryBot.create(:franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: franchise.id, franchise: { name: 'Lille' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not superuser' do
      it 'redirects to clients path' do
        session[:user_id] = current_user.id
        put :update, params: { id: franchise.id, franchise: { name: 'Lille' } }
        expect(response).to redirect_to(clients_path)
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: franchise.id, franchise: { name: '' } }
        }.not_to change(Franchise.all, :count)
      end
    end
    it 'updates franchise' do
      expect {
        current_user.update superuser: true
        session[:user_id] = current_user.id
        put :update, params: { id: franchise.id, franchise: { name: 'Lille' } }
      }.not_to change(Franchise.all, :count)
      expect(franchise.reload.name).to eq('Lille')
    end
  end
end
