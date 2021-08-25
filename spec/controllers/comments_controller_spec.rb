require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { client_id: client.id, comment: { body: 'Hello World!' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { client_id: client.id, comment: { body: '' } }
        }.not_to change(client.comments, :count)
      end
    end
    it 'creates comment' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { client_id: client.id, comment: { body: 'Hello World!' } }
      }.to change(client.comments, :count).by(1)
      expect(Comment.last.user).to eq(current_user)
      expect(Comment.last.body).to eq('Hello World!')
    end
  end

  describe 'PUT /:id' do
    let!(:comment) { FactoryBot.create(:comment, client: client) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { client_id: client.id, id: comment.id, comment: { body: 'New Lorem Ipsum' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { client_id: client.id, id: comment.id, comment: { body: '' } }
        }.not_to change(comment.reload, :body)
      end
    end
    context 'when superuser' do
      it 'updates body' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { client_id: client.id, id: comment.id, comment: { body: 'New Lorem Ipsum' } }
        }.not_to change(current_user.franchise.comments, :count)
        expect(comment.reload.body).to eq('New Lorem Ipsum')
      end
    end
    it 'updates comment' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { client_id: client.id, id: comment.id, comment: { body: 'New Lorem Ipsum' } }
      }.not_to change(current_user.franchise.comments, :count)
        expect(comment.reload.body).to eq('New Lorem Ipsum')
    end
  end

  describe 'DELETE /:id' do
    let!(:comment) { FactoryBot.create(:comment, client: client) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { client_id: client.id, id: comment.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        delete :destroy, params: { client_id: client.id, id: 0 }
        expect(response.status).to eq(404)
      end
    end
    it 'deletes comment' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { client_id: client.id, id: comment.id }
      }.to change(current_user.franchise.comments, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { client_id: client.id, id: comment.id }
      expect(response.status).to eq(204)
    end
  end
end
