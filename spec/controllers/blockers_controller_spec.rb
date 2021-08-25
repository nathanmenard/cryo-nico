require 'rails_helper'

RSpec.describe BlockersController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:blocker_2) { FactoryBot.create(:blocker) }
  let(:franchise_2) { FactoryBot.create(:franchise) }
  let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { blocker: { room_id: room.id, start_time: '2021-02-14T09:00', end_time: '2021-02-14T11:00', notes: 'Hello..' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { blocker: { room_id: room.id, start_time: '2021-02-14T09:00', end_time: '2021-02-14T11:00' } }
        }.not_to change(current_user.franchise.blockers, :count)
      end
    end
    context 'when superuser' do
      it 'creates blocker for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { blocker: { franchise_id: franchise_2.id, room_id: room.id, start_time: '2021-02-14T09:00', end_time: '2021-02-14T11:00', notes: 'Hello..' } }
        }.to change(franchise_2.blockers, :count).by(1)
        expect(Blocker.last.user).to eq(current_user)
        expect(Blocker.last.start_time).to eq('2021-02-14T09:00:00+01')
        expect(Blocker.last.end_time).to eq('2021-02-14T11:00:00+01')
        expect(Blocker.last.notes).to eq('Hello..')
        expect(Blocker.last.room).to eq(room)
      end
    end
    it 'creates blocker' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { blocker: { room_id: room.id, start_time: '2021-02-14T09:00', end_time: '2021-02-14T11:00', notes: 'Hello..' } }
      }.to change(current_user.franchise.blockers, :count).by(1)
      expect(Blocker.last.user).to eq(current_user)
      expect(Blocker.last.start_time).to eq('2021-02-14T09:00:00+01')
      expect(Blocker.last.end_time).to eq('2021-02-14T11:00:00+01')
      expect(Blocker.last.notes).to eq('Hello..')
        expect(Blocker.last.room).to eq(room)
    end
  end

  describe 'PUT /:id' do
    let!(:blocker) { FactoryBot.create(:blocker, franchise: current_user.franchise) }
    let!(:blocker_2) { FactoryBot.create(:blocker) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: blocker.id, blocker: { end_time: '2021-02-15T09:00' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: blocker.id, blocker: { end_time: '' } }
        }.not_to change(current_user.franchise.blockers, :count)
      end
    end
    context 'when superuser' do
      it 'updates blocker' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        put :update, params: { id: blocker_2.id, blocker: { end_time: '2021-02-15T09:00' } }
        expect(blocker_2.reload.end_time).to eq('2021-02-15T09:00:00+01')
      end
    end
    it 'updates blocker' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: blocker.id, blocker: { end_time: '2021-02-15T09:00' } }
      }.not_to change(current_user.franchise.blockers, :count)
      expect(blocker.reload.end_time).to eq('2021-02-15T09:00:00+01')
    end
  end

  describe 'DELETE /:id' do
    let!(:blocker) { FactoryBot.create(:blocker, franchise: current_user.franchise) }
    let!(:blocker_2) { FactoryBot.create(:blocker) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: blocker.id }
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
      context 'when blocker from another franchise' do
        it 'deletes blocker' do
          current_user.update superuser: true
          expect {
            session[:user_id] = current_user.id
            delete :destroy, params: { id: blocker_2.id }
          }.to change(blocker_2.franchise.blockers, :count).by(-1)
        end
      end
    end
    it 'deletes blocker' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: blocker.id }
      }.to change(current_user.franchise.blockers, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: blocker.id }
      expect(response.status).to eq(204)
    end
  end
end
