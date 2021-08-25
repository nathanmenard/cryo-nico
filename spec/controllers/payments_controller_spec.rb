require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
  let!(:payment_2) { FactoryBot.create(:payment, :successful) }
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
        it 'returns all payments from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: payment_2.client.franchise_id }
          expect(assigns(:payments)).to eq([payment_2])
        end
      end
      it 'returns all payments' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:payments).pluck(:id)).to eq(Payment.all.pluck(:id))
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
    context 'when has date filter' do
      it 'returns payments for given day && current franchise' do
        yesterday = Date.today - 1.day
        payment_a = FactoryBot.create(:payment, :successful, client: client, updated_at: yesterday)
        payment_b = FactoryBot.create(:payment, :successful, client: client)
        session[:user_id] = current_user.id
        get :index, params: { date: yesterday.to_s }
        expect(assigns(:payments)).to eq([payment_a])
      end
    end
    context 'when has view filter' do
      context 'when view == month' do
        context 'when date param' do
          it 'returns payments for given month' do
            last_month = Date.today - 1.month
            payment_a = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today)
            payment_b = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today - 1.month)
            payment_c = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today - 1.month)
            payment_d = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today + 1.month)
            session[:user_id] = current_user.id
            get :index, params: { view: 'month', date: last_month.to_s }
            expect(assigns(:payments)).to eq([payment_b, payment_c])
          end
        end
        it 'returns payments for current month' do
          payment_a = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today)
          payment_b = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today - 1.month)
          payment_b = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today + 1.month)
          session[:user_id] = current_user.id
          get :index, params: { view: 'month' }
          expect(assigns(:payments)).to eq([payment_a])
        end
      end
      context 'when view == year' do
        context 'when date param' do
          it 'returns payments for given year' do
            last_year = Date.today - 1.year
            payment_a = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today)
            payment_b = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today - 1.year)
            payment_c = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today - 1.year)
            payment_d = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today + 1.month)
            session[:user_id] = current_user.id
            get :index, params: { view: 'year', date: last_year.to_s }
            expect(assigns(:payments)).to eq([payment_b, payment_c])
          end
        end
        it 'returns payments for current year' do
          payment_a = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today)
          payment_b = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today - 1.year)
          payment_b = FactoryBot.create(:payment, :successful, client: client, updated_at: Date.today + 1.year)
          session[:user_id] = current_user.id
          get :index, params: { view: 'year' }
          expect(assigns(:payments)).to eq([payment_a])
        end
      end
    end
    it 'assigns @client' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:client).franchise).to eq(current_user.franchise)
    end
    it 'returns all payments of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:payments)).to eq(current_user.franchise.payments)
    end
  end

  describe 'GET :show' do
    let!(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
    let!(:payment) { FactoryBot.create(:payment, client: client) }
    let!(:payment_2) { FactoryBot.create(:payment) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { format: :pdf, id: payment.date_id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        get :show, params: { format: :pdf, id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when superuser' do
      context 'when payment from another franchise' do
        it 'renders payment page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { format: :pdf, id: payment_2.date_id }
          expect(assigns(:payment)).to eq(payment_2)
        end
      end
    end
    it 'renders payment page' do
      session[:user_id] = current_user.id
      get :show, params: { format: :pdf, id: payment.date_id }
      expect(assigns(:payment)).to eq(payment)
    end
  end

  describe 'POST :create' do
    let(:external_product) { FactoryBot.create(:external_product) }
    let(:product_price) { FactoryBot.create(:product_price, session_count: 3) }
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { payment: { client_id: client.id, external_product_id: external_product.id, mode: 'cash' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { payment: { client_id: client.id, mode: 'cash' } }
        }.not_to change(current_user.franchise.payments, :count)
      end
    end
    context 'when superuser' do
      xit 'creates room for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { room: { franchise_id: franchise_2.id, name: 'Ma salle', capacity: '5' } }
        }.to change(franchise_2.rooms, :count).by(1)
        expect(Room.last.name).to eq('Ma salle')
        expect(Room.last.capacity).to eq(5)
      end
    end
    context 'when external product' do
      it 'creates payment' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { payment: { client_id: client.id, external_product_id: external_product.id, product_price_id: '', mode: 'cash' } }
        }.to change(current_user.franchise.payments, :count).by(1)
        expect(Payment.last.client).to eq(client)
        expect(Payment.last.product_name).to eq(external_product.name)
        expect(Payment.last.amount).to eq(external_product.amount*100)
        expect(Payment.last.mode).to eq('cash')
      end
    end
    context 'when session_count && price_per_seance' do
      it 'creates payment'
      it 'generates credits'
    end
    context 'when product' do
      it 'creates payment' do
        expect do
          session[:user_id] = current_user.id
          post :create, params: { payment: { client_id: client.id, external_product_id: '', product_id: product_price.product.id, session_count: '1', session_price: '50', mode: 'cash' } }
        end.to change(current_user.franchise.payments, :count).by(1)
        expect(Payment.last.client).to eq(client)
        expect(Payment.last.product_name).to eq("#{product_price.product.name} (1 séance)")
        expect(Payment.last.amount).to eq(50*100)
        expect(Payment.last.mode).to eq('cash')
      end
      it 'generates credits' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { payment: { client_id: client.id, external_product_id: '', product_id: product_price.product.id, session_count: '3', session_price: '40', mode: 'cash' } }
        }.to change(client.credits.where(product: product_price.product), :count).from(0).to(3)
      end
    end
    context 'when new client' do
      it 'sends invite email' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { payment: { client_id: client.id, new_client: 'true', external_product_id: external_product.id, product_price_id: '', mode: 'cash' } }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
        expect(ActionMailer::Base.deliveries.first.to).to eq([client.email])
        expect(ActionMailer::Base.deliveries.first.subject).to eq('Vous avez été invité à rejoindre Cryotera !')
        expect(ActionMailer::Base.deliveries.first.body.decoded).to match(client.first_name)
      end
    end
  end

  describe 'PUT :update' do
    let!(:payment) { FactoryBot.create(:payment, client: client) }
    let!(:reservation) { FactoryBot.create(:reservation, payment: payment) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: payment.id, payment: { as_paid: 'true' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: payment.id, payment: { hello: 'ok' } }
        }.not_to change(payment, :attributes)
      end
    end
    context 'when as_paid attribute changed to true' do
      it 'updates payment as_paid column to true' do
        session[:user_id] = current_user.id
        put :update, params: { id: payment.id, payment: { as_paid: 'true' } }
        expect(payment.reload.as_paid).to eq(true)
      end
      context 'when reservation was not paid' do
        it 'sends invoice via mail' do
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: payment.id, payment: { as_paid: 'true' } }
          }.to change(ActionMailer::Base.deliveries, :count).by(1)
          expect(ActionMailer::Base.deliveries.first.to).to eq([payment.client.email])
          expect(ActionMailer::Base.deliveries.first.subject).to eq('Votre facture')
        end
      end
      context 'when reservation was already paid' do
        it 'does not send invoice' do
          payment.update(as_paid: true)
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: payment.id, payment: { as_paid: 'true' } }
          }.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end
      it 'redirects to reservations path' do
        session[:user_id] = current_user.id
        put :update, params: { id: payment.id, payment: { as_paid: 'true' } }
        expect(response).to redirect_to(reservations_path)
      end
    end
  end

  describe 'DELETE :destroy' do
    let!(:payment) { FactoryBot.create(:payment, client: client) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: payment.id }
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
    it 'deletes payment' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: payment.id }
      }.to change(current_user.franchise.payments, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: payment.id }
      expect(response.status).to eq(204)
    end
  end
end
