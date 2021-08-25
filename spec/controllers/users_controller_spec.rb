require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:user_2) { FactoryBot.create(:user) }
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
        it 'returns all users from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: user_2.franchise_id }
          expect(assigns(:users)).to eq(user_2.franchise.users)
        end
      end
      it 'returns all users' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:users)).to eq(User.all)
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
    it 'returns all users of current user' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:users)).to eq(current_user.franchise.users)
    end
  end

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { user: { email: 'hello@gmail.com', first_name: 'john', last_name: 'doe' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { user: { email: nil } }
        }.not_to change(current_user.franchise.users, :count)
      end
    end
    context 'when superuser' do
      it 'creates user for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { user: { franchise_id: franchise_2.id, email: 'hello@gmail.com', first_name: 'john', last_name: 'doe' } }
        }.to change(franchise_2.users, :count).by(1)
        expect(User.last.email).to eq('hello@gmail.com')
        expect(User.last.first_name).to eq('john')
        expect(User.last.last_name).to eq('doe')
        expect(User.last.franchise).to eq(franchise_2)
      end
    end
    it 'creates user' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { user: { email: 'hello@gmail.com', first_name: 'john', last_name: 'doe' } }
      }.to change(current_user.franchise.users, :count).by(1)
      expect(User.last.email).to eq('hello@gmail.com')
      expect(User.last.first_name).to eq('john')
      expect(User.last.last_name).to eq('doe')
    end
    it 'sends welcome email to user' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { user: { email: 'hello@gmail.com', first_name: 'john', last_name: 'doe' } }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe 'PUT /:id' do
    let!(:user) { FactoryBot.create(:user, franchise: current_user.franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: user.id, user: { first_name: 'adam' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :create, params: { user: { email: nil } }
        }.not_to change(current_user.franchise.users, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: user.id, user: { franchise_id: franchise_2.id, first_name: 'adam' } }
        }.to change(current_user.franchise.users, :count).by(-1)
        expect(user.reload.franchise).to eq(franchise_2)
        expect(user.reload.first_name).to eq('adam')
      end
    end
    it 'updates user' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: user.id, user: { first_name: 'adam' } }
      }.not_to change(current_user.franchise.users, :count)
      expect(user.reload.first_name).to eq('adam')
    end
  end

  describe 'GET /:id' do
    let!(:user) { FactoryBot.create(:user, franchise: current_user.franchise) }
    let!(:user_2) { FactoryBot.create(:user) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: user.id }
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
      context 'when user from another franchise' do
        it 'renders user page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: user_2.id }
          expect(assigns(:user)).to eq(user_2)
        end
      end
    end
    it 'renders user page' do
      session[:user_id] = current_user.id
      get :show, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'DELETE /:id' do
    let!(:user) { FactoryBot.create(:user, franchise: current_user.franchise) }
    let!(:user_2) { FactoryBot.create(:user) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        delete :destroy, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when superuser' do
      context 'when user from another franchise' do
        it 'deletes user' do
          current_user.update superuser: true
          expect {
            session[:user_id] = current_user.id
            delete :destroy, params: { id: user_2.id }
          }.to change(user_2.franchise.users, :count).by(-1)
        end
      end
    end
    it 'deletes user' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: user.id }
      }.to change(current_user.franchise.users, :count).by(-1)
    end
    it 'deletes comments associated' do
      comment = FactoryBot.create(:comment, user: user)
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: user.id }
      }.to change(Comment.all, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: user.id }
      expect(response.status).to eq(204)
    end
  end
end
