require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe 'POST /signup' do
    let!(:franchise) { FactoryBot.create(:franchise) }
    let!(:client) { FactoryBot.create(:client, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
    describe 'when not on subdomain' do
      it 'redirects to root path' do
        post :signup, params: { email: client.email, password: 'azerty' }
        expect(session[:user_id]).to eq(nil)
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'when invalid payload' do
      it 'displays error' do
        request.host = "#{franchise.slug}.lvh.me"
        post :signup, params: { client: { first_name: 'Adam' } }
        expect(session[:client_id]).to eq(nil)
        expect(response).to render_template(:signup)
      end
    end
    context 'when company id param' do
      let(:company_client) { FactoryBot.create(:company_client) }
      it 'updates company client record' do
        expect {
          request.host = "#{company_client.company.franchise.slug}.lvh.me"
          post :signup, params: { company_id: company_client.company.id, key: company_client.private_key, company_client: { first_name: 'Adam', last_name: 'Smith', email: client.email, password: 'azerty', } }
        }.not_to change(company_client.company.company_clients, :count)
        expect(company_client.reload.last_name).to eq('Smith')
        expect(company_client.reload.first_name).to eq('Adam')
        expect(company_client.reload.email).to eq(client.email)
        expect(company_client.reload.password_digest).not_to be_nil
        expect(company_client.reload.last_logged_at).not_to be_nil
      end
      it 'creates company client session' do
        request.host = "#{company_client.company.franchise.slug}.lvh.me"
        post :signup, params: { company_id: company_client.company.id, key: company_client.private_key, company_client: { first_name: 'Adam', last_name: 'Smith', email: client.email, password: 'azerty', } }
        expect(session[:company_client_id]).to eq(company_client.id)
      end
    end
    context 'when no company id param' do
      context 'when client id param' do
        it 'assigns new client to existing client' do
          client = FactoryBot.create(:client, franchise: franchise)
          expect {
            request.host = "#{franchise.slug}.lvh.me"
            post :signup, params: { client: { client_id: client.id, first_name: 'Adam', last_name: 'Smith', email: client.email, password: 'azerty', male: true, birth_date: '01/01/1990', objectives: ['sport', 'look'], newsletter: true } }
          }.to change(franchise.clients, :count).by(1)
          expect(Client.last.client).to eq(client)
          expect(Client.last.last_name).to eq('Smith')
          expect(Client.last.first_name).to eq('Adam')
          expect(Client.last.male).to eq(true)
          expect(Client.last.objectives).to eq(['sport', 'look'])
          expect(Client.last.newsletter).to eq(true)
          expect(Client.last.email).to eq(client.email)
          expect(Client.last.password_digest).not_to be_nil
          expect(Client.last.last_logged_at).not_to be_nil
        end
      end
      it 'creates client record' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :signup, params: { client: { first_name: 'Adam', last_name: 'Smith', email: client.email, password: 'azerty', male: true, birth_date: '01/01/1990', objectives: ['sport', 'look'], newsletter: true } }
        }.to change(franchise.clients, :count).by(1)
        expect(Client.last.last_name).to eq('Smith')
        expect(Client.last.first_name).to eq('Adam')
        expect(Client.last.male).to eq(true)
        expect(Client.last.objectives).to eq(['sport', 'look'])
        expect(Client.last.newsletter).to eq(true)
        expect(Client.last.email).to eq(client.email)
        expect(Client.last.password_digest).not_to be_nil
        expect(Client.last.last_logged_at).not_to be_nil
      end
      it 'creates client session' do
        request.host = "#{franchise.slug}.lvh.me"
        post :signup, params: { client: { first_name: 'Adam', last_name: 'Smith', email: client.email, password: 'azerty', male: true, birth_date: '01/01/1990', objectives: ['sport', 'look'], newsletter: true } }
        expect(session[:client_id]).to eq(Client.last.id)
      end
    end
    it 'redirects to account form' do
      request.host = "#{franchise.slug}.lvh.me"
      post :signup, params: { client: { first_name: 'Adam', last_name: 'Smith', email: client.email, password: 'azerty', male: true, birth_date: '01/01/1990', objectives: ['sport', 'look'], newsletter: true } }
      expect(response).to redirect_to root_path
    end
  end

  describe 'POST /login' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:client) { FactoryBot.create(:client, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
    let(:company) { FactoryBot.create(:company, franchise: franchise) }
    let(:company_client) { FactoryBot.create(:company_client, company: company, email: 'me@gmail.com', password: 'azerty') }
    describe 'when not on subdomain' do
      it 'redirects to root path' do
        post :login, params: { email: client.email, password: 'azerty' }
        expect(session[:user_id]).to eq(nil)
        expect(response).to redirect_to(root_path)
      end
    end
    context 'when client' do
      describe 'when invalid credentials' do
        it 'does not create session' do
          request.host = "#{franchise.slug}.lvh.me"
          post :login, params: { email: client.email, password: 'invalid password' }
          expect(session[:client_id]).to eq(nil)
          expect(response).to render_template(:login)
        end
      end
      it 'creates session for client' do
        request.host = "#{franchise.slug}.lvh.me"
        post :login, params: { email: client.email, password: 'azerty' }
        expect(session[:client_id]).to eq(client.id)
        expect(response).to redirect_to(root_path)
      end
      it 'updates last_logged_at for client' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :login, params: { email: client.email, password: 'azerty' }
        }.to change { client.reload.last_logged_at }
      end
    end
    context 'when company client' do
      describe 'when invalid credentials' do
        it 'does not create session' do
          request.host = "#{franchise.slug}.lvh.me"
          post :login, params: { email: company_client.email, password: 'invalid password' }
          expect(session[:company_client_id]).to eq(nil)
          expect(response).to render_template(:login)
        end
      end
      it 'creates session for client' do
        request.host = "#{franchise.slug}.lvh.me"
        post :login, params: { email: company_client.email, password: 'azerty' }
        expect(session[:company_client_id]).to eq(company_client.id)
        expect(response).to redirect_to(root_path)
      end
      it 'updates last_logged_at for client' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :login, params: { email: company_client.email, password: 'azerty' }
        }.to change { company_client.reload.last_logged_at }
      end
    end
    context 'when has redirect_to' do
      it 'redirects back' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:redirect_to] = contact_path
        post :login, params: { email: client.email, password: 'azerty' }
        expect(response).to redirect_to(contact_path)
      end
    end
  end

  describe 'POST /mon-compte' do
    let!(:franchise) { FactoryBot.create(:franchise) }
    let!(:client) { FactoryBot.create(:client, franchise: franchise, email: 'me@gmail.com', password: 'azerty') }
    let(:company) { FactoryBot.create(:company, franchise: franchise) }
    let!(:company_client) { FactoryBot.create(:company_client, company: company, email: 'me@gmail.com', password: 'azerty') }
    describe 'when not on subdomain' do
      it 'redirects to root path' do
        session[:client_id] = client.id
        patch :edit_account, params: { client: { email: 'hi@gmail.com' } }
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'when not logged in' do
      it 'redirects to login path' do
        request.host = "#{franchise.slug}.lvh.me"
        patch :edit_account, params: { client: { email: 'hi@gmail.com' } }
        expect(response).to redirect_to(login_path)
      end
    end
    describe 'when invalid payload' do
      it 'displays error' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        patch :edit_account, params: { client: { email: 'invalid email' } }
        expect(response).to render_template(:edit_account)
        expect(client.reload.email).to eq('me@gmail.com')
      end
    end
    context 'when company client' do
      it 'updates client record' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        patch :edit_account, params: { company_client: { email: 'hello@gmail.com' } }
        expect(company_client.reload.email).to eq('hello@gmail.com')
      end
    end
    context 'when client' do
    it 'updates client record' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      patch :edit_account, params: { client: { email: 'hello@gmail.com' } }
      expect(client.reload.email).to eq('hello@gmail.com')
    end
  end
end

describe 'POST /admin' do
  let(:user) { FactoryBot.create(:user, email: 'me@gmail.com', password: 'azerty') }
  describe 'when invalid credentials' do
    it 'does not create session' do
      post :admin, params: { email: user.email, password: 'invalid password' }
      expect(session[:user_id]).to eq(nil)
      expect(response).to render_template(:admin)
    end
  end
  it 'creates session for user' do
    post :admin, params: { email: user.email, password: 'azerty' }
    expect(session[:user_id]).to eq(user.id)
    expect(response).to redirect_to clients_path
  end
  it 'updates last_logged_at attribute' do
    expect {
      post :admin, params: { email: user.email, password: 'azerty' }
    }.to change { user.reload.last_logged_at }
  end
  context 'when has redirect_to' do
    it 'redirects back' do
      session[:redirect_to] = coupons_path
      post :admin, params: { email: user.email, password: 'azerty' }
      expect(response).to redirect_to(coupons_path)
    end
  end
end

describe 'POST /admin/inscription' do
  let(:user) { FactoryBot.create(:user, email: 'me@gmail.com') }
  describe 'when not on subdomain' do
    it 'redirects to root path' do
      patch :admin_signup, params: { key: 'invalid key', user: { password: 'azerty' } }
      expect(response).to redirect_to(root_path)
    end
  end
  describe 'when invalid key' do
    it 'redirects to root_path' do
      request.host = "#{user.franchise.slug}.lvh.me"
      patch :admin_signup, params: { key: 'invalid key', user: { password: 'azerty' } }
      expect(response).to redirect_to(root_path)
    end
  end
  it 'saves password for user' do
    request.host = "#{user.franchise.slug}.lvh.me"
    patch :admin_signup, params: { key: user.private_key, user: { password: 'azerty' } }
    expect(user.password).not_to be_nil
  end
  it 'creates session for user' do
    request.host = "#{user.franchise.slug}.lvh.me"
    patch :admin_signup, params: { key: user.private_key, user: { password: 'azerty' } }
    expect(session[:user_id]).to eq(user.id)
    expect(response).to redirect_to(clients_path)
  end
end
end
