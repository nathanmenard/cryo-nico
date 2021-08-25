require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  describe 'GET :new' do
    let(:franchise) { FactoryBot.create(:franchise) }
    describe 'when not on subdomain' do
      it 'displays form' do
        get :new
        expect(response).to render_template(:new)
      end
    end
    context 'when on subdomain' do
      it 'displays form' do
        request.host = "#{franchise.slug}.lvh.me"
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST :new' do
    let(:franchise) { FactoryBot.create(:franchise) }
    describe 'when on subdomain' do
      let(:client) { FactoryBot.create(:client, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
      describe 'when unfound client email' do
        let(:client_2) { FactoryBot.create(:client) }
        it 'does not send email' do
          expect {
            request.host = "#{franchise.slug}.lvh.me"
            post :new, params: { email: client_2.email }
          }.not_to change(ActionMailer::Base.deliveries, :count)
          expect(response).to render_template(:new)
        end
      end
      it 'sends email to client' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :new, params: { email: client.email }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(response).to render_template(:new)
      end
    end
    describe 'when on root domain' do
      let(:user) { FactoryBot.create(:user, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
      describe 'when unfound user email' do
        it 'does not send email' do
          expect {
            post :new, params: { email: 'unknown@email.com' }
          }.not_to change(ActionMailer::Base.deliveries, :count)
          expect(response).to render_template(:new)
        end
      end
      it 'sends email to user' do
        expect {
          post :new, params: { email: user.email }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST /nouveau-mot-de-passe' do
    let(:franchise) { FactoryBot.create(:franchise) }
    context 'when on subdomain' do
      let(:client) { FactoryBot.create(:client, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
      describe 'when unfound client key' do
        let(:client_2) { FactoryBot.create(:client) }
        it 'redirects to root path' do
          request.host = "#{franchise.slug}.lvh.me"
          post :create, params: { key: client_2.private_key, password: 'said', password_2: 'said' }
          expect(response).to redirect_to(root_path)
        end
      end
      describe 'when both passwords do not match' do
        it 'displays error' do
          request.host = "#{franchise.slug}.lvh.me"
          post :create, params: { key: client.private_key, password: 'said', password_2: 'said1' }
          expect(response).to render_template(:new)
        end
      end
      it 'saves new password' do
        password_digest = client.password_digest
        request.host = "#{franchise.slug}.lvh.me"
        post :create, params: { key: client.private_key, password: 'said', password_2: 'said' }
        expect(client.reload.password_digest).not_to eq(password_digest)
      end
      it 'creates session' do
        request.host = "#{franchise.slug}.lvh.me"
        post :create, params: { key: client.private_key, password: 'said', password_2: 'said' }
        expect(session[:client_id]).to eq(client.id)
      end
      it 'redirects to root path' do
        request.host = "#{franchise.slug}.lvh.me"
        post :create, params: { key: client.private_key, password: 'said', password_2: 'said' }
        expect(response).to redirect_to root_path
      end
    end
    context 'when on root domain' do
      let(:user) { FactoryBot.create(:user, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
      describe 'when unfound user key' do
        it 'redirects to root path' do
          post :create, params: { key: 'unknown private key', password: 'said', password_2: 'said' }
          expect(response).to redirect_to(root_path)
        end
      end
      describe 'when both passwords do not match' do
        it 'displays error' do
          post :create, params: { key: user.private_key, password: 'said', password_2: 'said1' }
          expect(response).to render_template(:new)
        end
      end
      it 'saves new password' do
        password_digest = user.password_digest
        post :create, params: { key: user.private_key, password: 'said', password_2: 'said' }
        expect(user.reload.password_digest).not_to eq(password_digest)
      end
      it 'creates session' do
        post :create, params: { key: user.private_key, password: 'said', password_2: 'said' }
        expect(session[:user_id]).to eq(user.id)
      end
      it 'redirects to clients path' do
        post :create, params: { key: user.private_key, password: 'said', password_2: 'said' }
        expect(response).to redirect_to clients_path
      end
    end
  end
end
