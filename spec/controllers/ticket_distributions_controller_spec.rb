require 'rails_helper'

RSpec.describe TicketDistributionsController, type: :controller do
  let(:franchise) { FactoryBot.create(:franchise, banking_secret_id: 'abc', banking_secret_key: 'foo') }
  let(:company) { FactoryBot.create(:company, franchise: franchise) }
  let(:client) { FactoryBot.create(:client, franchise: franchise) }
  let!(:company_client) { FactoryBot.create(:company_client, company: company) }
  let(:room) { FactoryBot.create(:room, franchise: franchise) }
  let(:product) { FactoryBot.create(:product, room: room) }
  let(:product_price) { FactoryBot.create(:product_price, product: product, professionnal: true) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when current client is not professional' do
      it 'redirects to root path' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
    it 'displays current client credits for all products' do
      credit_a = FactoryBot.create(:credit, company_client: company_client)
      credit_b = FactoryBot.create(:credit, company_client: company_client)

      request.host = "#{franchise.slug}.lvh.me"
      session[:company_client_id] = company_client.id
      get :index
      expect(assigns(:credits)).to eq([credit_a, credit_b])
    end
  end

  describe 'GET :new' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :new, params: { product_id: product.id }
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when current client is not professional' do
      it 'redirects to root path' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :new, params: { product_id: product.id }
        expect(response).to redirect_to(root_path)
      end
    end
    context 'when product does not exist' do
      it 'displays 404' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        get :new, params: { product_id: 1 }
        expect(response.status).to eq(404)
      end
    end
    context 'when current company client does not have a credit to give' do
      it 'redirects to product page' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        get :new, params: { product_id: product.id }
        expect(response).to redirect_to(product_path(id: product.slug))
      end
    end
    it 'assigns @company_clients' do
      company_client_child_a = FactoryBot.create(:company_client, company: company, company_client: company_client)
      company_client_child_b = FactoryBot.create(:company_client, company: company, company_client: company_client)
      FactoryBot.create(:credit, company_client: company_client, product: product)
      request.host = "#{franchise.slug}.lvh.me"
      session[:company_client_id] = company_client.id
      get :new, params: { product_id: product.id }
      expect(assigns(:company_clients).pluck(:id).sort).to eq([company_client_child_a.id, company_client_child_b.id].sort)
    end
  end

  describe 'POST :create' do
    let!(:company_client_2) { FactoryBot.create(:company_client, company: company, email: 'bill@microsoft.com') }
    context 'when current company client does not have a credit to give' do
      it 'redirects to root page' do
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com', quantity: '1' }
          expect(response).to redirect_to(product_path(id: product.slug))
      end
    end
    context 'when has no quantity' do
      it 'redirects to :new' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com' }
        expect(response).to redirect_to(new_ticket_distribution_path(product_id: product.id))
      end
    end
    context 'when quantity > available credits' do
      it 'redirects to :new' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com', quantity: '2' }
        expect(response).to redirect_to(new_ticket_distribution_path(product_id: product.id))
      end
    end
    context 'when end user does not exist' do
      it 'creates user' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com', quantity: '1' }
        }.to change(company.company_clients, :count).by(1)
        expect(company.company_clients.last.company_client).to eq(company_client)
        expect(company.company_clients.last.email).to eq('bill@microsoft.com')
        expect(company.company_clients.last.last_name).to eq('Gates')
        expect(company.company_clients.last.first_name).to eq('Bill')
      end
      it 'assigns credit to end user' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com', quantity: '1' }
        expect(CompanyClient.last.credits.where(product: product).count).to eq(1)
      end
      it 'sends welcome email + distribution to new user' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        expect do
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com', quantity: '1' }
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
        expect(ActionMailer::Base.deliveries.first.to).to eq(['bill@microsoft.com'])
        expect(ActionMailer::Base.deliveries.first.subject).to eq('Vous venez de recevoir un crédit !')
        expect(ActionMailer::Base.deliveries.first.body.decoded).to match(product.name)
      end
    end
    context 'when end user already exists' do
      it 'does not create a new user' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          post :create, params: { product_id: product.id, company_client_id: company_client_2.id, quantity: '1' }
        }.not_to change(company.company_clients, :count)
      end
      it 'assigns credit to end user' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        expect do
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          post :create, params: { product_id: product.id, company_client_id: company_client_2.id, quantity: '1' }
        end.to change(company_client_2.credits, :count).by(1)
        expect(company_client_2.credits.last.product).to eq(product)
      end
      it 'sends email to end user' do
        FactoryBot.create(:credit, company_client: company_client, product: product)
        expect do
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          post :create, params: { product_id: product.id, company_client_id: company_client_2.id, quantity: '1' }
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
        expect(ActionMailer::Base.deliveries.first.to).to eq(['bill@microsoft.com'])
        expect(ActionMailer::Base.deliveries.first.subject).to eq('Vous venez de recevoir un crédit !')
        expect(ActionMailer::Base.deliveries.first.body.decoded).to match(product.name)
      end
    end
    it 'assigns x credit' do
      10.times { FactoryBot.create(:credit, company_client: company_client, product: product) }
      expect do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        post :create, params: { product_id: product.id, company_client_id: company_client_2.id, quantity: '8' }
      end.to change(company_client_2.credits, :count).by(8)
      expect(company_client_2.credits.last.product).to eq(product)
      expect(company_client.credits.count).to eq(2)
    end
  end
  it 'removes credit from first user' do
    FactoryBot.create(:credit, company_client: company_client, product: product)
    expect do
      request.host = "#{franchise.slug}.lvh.me"
      session[:company_client_id] = company_client.id
      post :create, params: { product_id: product.id, first_name: 'Bill', last_name: 'Gates', email: 'bill@microsoft.com', quantity: '1' }
    end.to change(company_client.credits, :count).by(-1)
  end
end
