require 'rails_helper'

RSpec.describe CompanyClientsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:company) { FactoryBot.create(:company, franchise: current_user.franchise) }

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { company_id: company.id, company_client: { first_name: 'john', last_name: 'doe', email: 'john@doe.com' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { company_id: company.id, company_client: { first_name: nil } }
        }.not_to change(company.company_clients, :count)
      end
    end
    it 'creates client' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { company_id: company.id, company_client: { first_name: 'john', last_name: 'doe', email: 'john@doe.com' } }
      }.to change(company.company_clients, :count).by(1)
      expect(CompanyClient.last.company).to eq(company)
      expect(CompanyClient.last.first_name).to eq('john')
      expect(CompanyClient.last.last_name).to eq('doe')
      expect(CompanyClient.last.email).to eq('john@doe.com')
    end
    it 'sends email to client' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { company_id: company.id, company_client: { first_name: 'john', last_name: 'doe', email: 'john@doe.com' } }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
