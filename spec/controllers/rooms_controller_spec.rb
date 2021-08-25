require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:room_2) { FactoryBot.create(:room) }
  let(:franchise_2) { FactoryBot.create(:franchise) }

  describe 'GET /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to('/admin')
      end
    end
    context 'superuser' do
      context 'when filter by franchise' do
        it 'returns all rooms from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: room_2.franchise_id }
          expect(assigns(:rooms)).to eq([room_2])
        end
      end
      it 'returns all rooms' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:rooms)).to eq(Room.all)
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
    it 'returns all rooms of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:rooms)).to eq(current_user.franchise.rooms)
    end
  end

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { room: { name: 'Ma salle', capacity: '5' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
        post :create, params: { room: { name: 'Ma salle' } }
        }.not_to change(current_user.franchise.rooms, :count)
      end
    end
    context 'when superuser' do
      it 'creates room for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { room: { franchise_id: franchise_2.id, name: 'Ma salle', capacity: '5' } }
        }.to change(franchise_2.rooms, :count).by(1)
        expect(Room.last.name).to eq('Ma salle')
        expect(Room.last.capacity).to eq(5)
      end
    end
    it 'creates room' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { room: { name: 'Ma salle', capacity: '5' } }
      }.to change(current_user.franchise.rooms, :count).by(1)
      expect(Room.last.name).to eq('Ma salle')
      expect(Room.last.capacity).to eq(5)
    end
  end

  describe 'PUT /:id' do
    let!(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: room.id, room: { capacity: '20' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: room.id, room: { name: '' } }
        }.not_to change(current_user.franchise.rooms, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: room.id, room: { franchise_id: franchise_2.id, capacity: '20' } }
        }.to change(current_user.franchise.rooms, :count).by(-1)
        expect(room.reload.franchise).to eq(franchise_2)
        expect(room.reload.capacity).to eq(20)
      end
    end
    it 'updates room' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: room.id, room: { capacity: '20' } }
      }.not_to change(current_user.franchise.rooms, :count)
      expect(room.reload.capacity).to eq(20)
    end
  end

  describe 'GET /:id' do
    let!(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
    let!(:room_2) { FactoryBot.create(:room) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: room.id }
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
      context 'when room from another franchise' do
        it 'renders room page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: room_2.id }
          expect(assigns(:room)).to eq(room_2)
        end
      end
    end
    it 'renders room page' do
      session[:user_id] = current_user.id
      get :show, params: { id: room.id }
      expect(assigns(:room)).to eq(room)
    end
  end

  describe 'DELETE /:id' do
    let!(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
    let!(:room_2) { FactoryBot.create(:room) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: room.id }
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
      context 'when room from another franchise' do
        it 'deletes room' do
          current_user.update superuser: true
          expect {
            session[:user_id] = current_user.id
            delete :destroy, params: { id: room_2.id }
          }.to change(room_2.franchise.rooms, :count).by(-1)
        end
      end
    end
    it 'deletes room' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: room.id }
      }.to change(current_user.franchise.rooms, :count).by(-1)
    end
    it 'deletes products associated' do
      product = FactoryBot.create(:product, room: room)
      product_price = FactoryBot.create(:product_price, product: product)
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: room.id }
      }.to change(current_user.franchise.products, :count).by(-1)
    end
    it 'deletes product prices associated' do
      product = FactoryBot.create(:product, room: room)
      product_price = FactoryBot.create(:product_price, product: product)
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: room.id }
      }.to change(current_user.franchise.product_prices, :count).by(-1)
    end
    xit 'deletes reservations associated' do
      product = FactoryBot.create(:product, room: room)
      product_price = FactoryBot.create(:product_price, product: product)
      reservation = FactoryBot.create(:reservation, product_price: product_price)
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: room.id }
      }.to change(current_user.franchise.reservations, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: room.id }
      expect(response.status).to eq(204)
    end
  end
end
