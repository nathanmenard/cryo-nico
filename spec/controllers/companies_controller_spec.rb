require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:company_2) { FactoryBot.create(:company) }
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
        it 'returns all companies from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: company_2.franchise }
          expect(assigns(:companies)).to eq([company_2])
        end
      end
      it 'returns all companies' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:companies)).to eq(Company.all)
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
    it 'returns all companies of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:companies)).to eq(current_user.franchise.companies)
    end
  end

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { company: { name: 'Microsoft', email: 'contact@microsoft.com', phone: '0620853909', address: 'Silicon Valley', zip_code: 12345, city: 'San Francisco', siret: '81214811200013' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { company: { name: nil } }
        }.not_to change(current_user.franchise.companies, :count)
      end
    end
    context 'when superuser' do
      it 'creates client for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { company: { franchise_id: franchise_2.id, name: 'Microsoft', email: 'contact@microsoft.com', phone: '0620853909', address: 'Silicon Valley', zip_code: 12345, city: 'San Francisco', siret: '81214811200013' } }
        }.to change(franchise_2.companies, :count).by(1)
        expect(Company.last.name).to eq('Microsoft')
        expect(Company.last.phone).to eq('0620853909')
        expect(Company.last.address).to eq('Silicon Valley')
        expect(Company.last.zip_code).to eq('12345')
        expect(Company.last.city).to eq('San Francisco')
        expect(Company.last.siret).to eq('81214811200013')
      end
    end
    it 'creates company' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { company: { name: 'Microsoft', email: 'contact@microsoft.com', phone: '0620853909', address: 'Silicon Valley', zip_code: 12345, city: 'San Francisco', siret: '81214811200013' } }
      }.to change(current_user.franchise.companies, :count).by(1)
      expect(Company.last.name).to eq('Microsoft')
      expect(Company.last.phone).to eq('0620853909')
      expect(Company.last.address).to eq('Silicon Valley')
      expect(Company.last.zip_code).to eq('12345')
      expect(Company.last.city).to eq('San Francisco')
      expect(Company.last.siret).to eq('81214811200013')
    end
  end

  describe 'PUT /:id' do
    let!(:company) { FactoryBot.create(:company, franchise: current_user.franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: company.id, company: { name: 'Mastercard' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: company.id, company: { name: 'Mastercard' } }
        }.not_to change(current_user.franchise.companies, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: company.id, company: { franchise_id: franchise_2.id, name: 'Mastercard' } }
        }.to change(current_user.franchise.companies, :count).by(-1)
        expect(company.reload.name).to eq('Mastercard')
      end
    end
    it 'updates company' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: company.id, company: { name: 'Mastercard' } }
      }.not_to change(current_user.franchise.companies, :count)
      expect(company.reload.name).to eq('Mastercard')
    end
  end

  describe 'GET /:id' do
    let!(:company) { FactoryBot.create(:company, franchise: current_user.franchise) }
    let!(:company_2) { FactoryBot.create(:company) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: company.id }
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
      context 'when company from another franchise' do
        it 'renders company page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: company_2.id }
          expect(assigns(:company)).to eq(company_2)
        end
      end
    end
    it 'renders company page' do
      session[:user_id] = current_user.id
      get :show, params: { id: company.id }
      expect(assigns(:company)).to eq(company)
    end
  end
end
