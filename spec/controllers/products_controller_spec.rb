require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
  let(:room_2) { FactoryBot.create(:room) }
  let!(:product_2) { FactoryBot.create(:product, room: room_2) }
  let(:room_3) { FactoryBot.create(:room) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to('/admin')
      end
    end
    context 'superuser' do
      context 'when filter by franchise' do
        it 'returns all products from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: product_2.room.franchise_id }
          expect(assigns(:products)).to eq([product_2])
        end
      end
      it 'returns all products' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:products)).to eq(Product.all)
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
    it 'returns all products of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:products)).to eq(current_user.franchise.products)
    end
  end

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { product: { room_id: room, name: 'Mon produit', description: 'Hey!', duration: '25' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { product: { name: '' } }
        }.not_to change(current_user.franchise.products, :count)
      end
    end
    context 'when superuser' do
      it 'creates product for given room of another franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { product: { room_id: room_2.id, name: 'Mon produit', description: 'Hey!', duration: '25' } }
        }.to change(room_2.franchise.products, :count).by(1)
        expect(Product.last.room).to eq(room_2)
        expect(Product.last.name).to eq('Mon produit')
        expect(Product.last.description).to eq('Hey!')
        expect(Product.last.duration).to eq(25)
      end
    end
    it 'creates product' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { product: { room_id: room, name: 'Mon produit', description: 'Hey!', duration: '25' } }
      }.to change(current_user.franchise.products, :count).by(1)
      expect(Product.last.room).to eq(room)
      expect(Product.last.name).to eq('Mon produit')
      expect(Product.last.description).to eq('Hey!')
      expect(Product.last.duration).to eq(25)
    end
  end

  describe 'PUT /:id' do
    let!(:product) { FactoryBot.create(:product, room: room) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: product.id, product: { duration: '60' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: product.id, product: { name: '' } }
        }.not_to change(current_user.franchise.products, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: product.id, product: { room_id: room_2.id, duration: '60' } }
        }.to change(current_user.franchise.products, :count).by(-1)
        expect(product.reload.room).to eq(room_2)
        expect(product.reload.duration).to eq(60)
      end
    end
    it 'updates product' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: product.id, product: { duration: '60' } }
      }.not_to change(current_user.franchise.products, :count)
      expect(product.reload.duration).to eq(60)
    end
  end

  describe 'GET /:id' do
    let!(:product) { FactoryBot.create(:product, room: room) }
    let!(:product_2) { FactoryBot.create(:product) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: product.id }
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
      context 'when product from another franchise' do
        it 'renders product page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: product_2.id }
          expect(assigns(:product)).to eq(product_2)
        end
      end
    end
    it 'renders product page' do
      session[:user_id] = current_user.id
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end
  end

  describe 'DELETE /:id' do
    let!(:product) { FactoryBot.create(:product, room: room) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: product.id }
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
    it 'deletes product' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: product.id }
      }.to change(current_user.franchise.products, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: product.id }
      expect(response.status).to eq(204)
    end
  end
end
