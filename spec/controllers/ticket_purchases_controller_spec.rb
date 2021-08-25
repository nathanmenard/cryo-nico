require 'rails_helper'

RSpec.describe TicketPurchasesController, type: :controller do
  let(:franchise) { FactoryBot.create(:franchise, banking_secret_id: 'abc', banking_secret_key: 'foo') }
  let(:company) { FactoryBot.create(:company, franchise: franchise) }
  let(:client) { FactoryBot.create(:client, franchise: franchise) }
  let(:company_client) { FactoryBot.create(:company_client, company: company) }
  let(:room) { FactoryBot.create(:room, franchise: franchise) }
  let(:product) { FactoryBot.create(:product, room: room) }
  let(:product_price) { FactoryBot.create(:product_price, product: product, professionnal: true) }

  describe 'GET :new' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :new, params: { product_price_id: product_price.id }
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when current client is not professional' do
      it 'redirects to root path' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :new, params: { product_price_id: product_price.id }
        expect(response).to redirect_to(root_path)
      end
    end
    context 'when franchise has no banking keys' do
      it 'raises error' do
        franchise.update(banking_secret_id: nil, banking_secret_key: nil)
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          session[:company_client_id] = company_client.id
          session[:cart] = [{ 'product_price_id' => product_price.id }]
          get :new, params: { product_price_id: product_price.id }
        }.to raise_error(RuntimeError, "Franchise #{franchise.name} has no banking keys")
      end
    end
    context 'when product_price_id is nil' do
      it 'returns 404' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        get :new
        expect(response.code).to eq('404')
      end
    end
    context 'when product_price_id does not exist' do
      it 'returns 404' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        get :new, params: { product_price_id: '123' }
        expect(response.code).to eq('404')
      end
    end
    it 'saves product_price_id in session' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:company_client_id] = company_client.id
      get :new, params: { product_price_id: product_price.id }
      expect(session[:cart]).to eq([{ 'product_price_id' => product_price.id }])
    end
    it 'creates payment' do
      expect do
        request.host = "#{franchise.slug}.lvh.me"
        session[:company_client_id] = company_client.id
        get :new, params: { product_price_id: product_price.id }
      end.to change(Payment, :count).by(1)
      expect(Payment.last.amount).to eq(3000)
      expect(Payment.last.company_client).to eq(company_client)
      expect(Payment.last.client).to eq(nil)
      expect(Payment.last.transaction_id).not_to be_nil
      expect(Payment.last.product_name).to eq(product_price.product.name)
    end
    xit 'displays banking form'
  end

  describe 'POST :callback' do
    let!(:payment) { FactoryBot.create(:payment, company_client: company_client) }
    let(:params) do
      {
        vads_trans_id: payment.transaction_id,
        vads_amount: payment.amount,
      }
    end
    context 'when cart is empty' do
      it 'redirects to root path' do
        session[:company_client_id] = company_client.id
        params[:vads_trans_status] = 'AUTHORISED'
        params[:vads_bank_label] = 'Société générale'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(false)
        expect(response).to redirect_to root_path
      end
    end
    context 'when vads_trans_status == AUTHORIZED' do
      it 'marks the payment as successful' do
        session[:cart] = [{ 'product_price_id' => product_price.id }]
        session[:company_client_id] = company_client.id
        params[:vads_bank_label] = 'Société générale'
        params[:vads_trans_status] = 'AUTHORISED'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(true)
      end
    end
    context 'when vads_trans_status == ACCEPTED' do
      it 'marks the payment as successful' do
        session[:cart] = [{ 'product_price_id' => product_price.id }]
        session[:company_client_id] = company_client.id
        params[:vads_bank_label] = 'Société générale'
        params[:vads_trans_status] = 'ACCEPTED'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(true)
      end
    end
    context 'when vads_trans_status is anything else' do
      it 'updates the paid status to failed' do
        session[:cart] = [{ 'product_price_id' => product_price.id }]
        session[:company_client_id] = company_client.id

        params[:vads_trans_status] = 'CANCELLED'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(false)

        params[:vads_trans_status] = 'EXPIRED'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(false)

        params[:vads_trans_status] = 'UNKNOWN'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(false)

        params[:vads_trans_status] = 'azerty'
        post :callback, params: params
        expect(payment.reload.successful?).to eq(false)
      end
    end
    it 'saves bank name' do
      session[:company_client_id] = company_client.id
      session[:cart] = [{ 'product_price_id' => product_price.id }]
      params[:vads_bank_label] = 'Société générale'
      params[:vads_trans_status] = 'AUTHORISED'
      post :callback, params: params
      expect(payment.reload.bank_name).to eq('Société générale')
    end
    it 'creates credits for company client' do
      expect {
        session[:company_client_id] = company_client.id
        session[:cart] = [{ 'product_price_id' => product_price.id }]
        params[:vads_trans_status] = 'AUTHORISED'
        post :callback, params: params
      }.to change(company_client.credits, :count).by(1)
      expect(company_client.credits.count).to eq(1)
      expect(company_client.credits.first.product).to eq(product_price.product)
    end
    xit 'sends invoice to company client'
    it 'empties cart' do
      session[:company_client_id] = company_client.id
      session[:cart] = [{ 'product_price_id' => product_price.id }]
      params[:vads_trans_status] = 'AUTHORISED'
      post :callback, params: params
      expect(session[:cart]).to be_nil
    end
    xit 'redirects to tickets_path' do
      session[:company_client_id] = company_client.id
      session[:cart] = [{ 'product_price_id' => product_price.id }]
      params[:vads_trans_status] = 'AUTHORISED'
      post :callback, params: params
      expect(response).to redirect_to('/distribution')
    end
  end
end
