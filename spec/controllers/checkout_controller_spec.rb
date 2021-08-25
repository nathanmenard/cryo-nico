require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  describe 'GET :new' do
    let(:franchise) { FactoryBot.create(:franchise, banking_secret_id: 'abc', banking_secret_key: 'foo') }
    let(:client) { FactoryBot.create(:client, franchise: franchise) }
    let(:room) { FactoryBot.create(:room, franchise: franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :new
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when franchise has no banking keys' do
      it 'raises error' do
        franchise.update banking_secret_id: nil, banking_secret_key: nil
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          session[:client_id] = client.id
          session[:cart] = [{ 'product_price_id' => product_price.id }]
          get :new
        }.to raise_error(RuntimeError, "Franchise #{franchise.name} has no banking keys")
      end
    end
    context 'when empty cart' do
      it 'redirects to root' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
    context 'when post request' do
      context 'when has coupon parameter' do
        context 'when coupon == "nil"' do
          it 'removes coupon from reservation' do
            coupon = FactoryBot.create(:coupon, franchises: [franchise])
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            session[:cart] = [{ 'product_price_id' => product_price.id }]
            get :new
            post :new, params: { id: franchise.reservations.first.id, coupon: coupon.code }
            expect(franchise.reservations.first.payment.coupon).to eq(coupon)
            get :new, params: { id: franchise.reservations.first.id, coupon: 'nil' }
            expect(franchise.reservations.first.payment.coupon).to eq(nil)
          end
          it 'does not change reservation amount' do
            coupon = FactoryBot.create(:coupon, franchises: [franchise])
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            session[:cart] = [{ 'product_price_id' => product_price.id }]
            get :new
            post :new, params: { id: franchise.reservations.first.id, coupon: coupon.code }
            expect(franchise.reservations.first.payment.reload.amount).to eq(2700)
            get :new, params: { id: franchise.reservations.first.id, coupon: 'nil' }
            expect(franchise.reservations.first.payment.reload.amount).to eq(3000)
          end
        end
        context 'when coupon is not applicable' do
          it 'does not add coupon to reservation' do
            coupon = FactoryBot.create(:coupon, franchises: [FactoryBot.create(:franchise)])
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            session[:cart] = [{ 'product_price_id' => product_price.id }]
            get :new
            post :new, params: { id: franchise.reservations.first.id, coupon: coupon.code }
            expect(franchise.reservations.first.payment.reload.coupon).to eq(nil)
          end
          it 'does not change reservation amount' do
            coupon = FactoryBot.create(:coupon)
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            session[:cart] = [{ 'product_price_id' => product_price.id }]
            get :new

            expect {
              post :new, params: { id: franchise.reservations.first.id, coupon: coupon.code }
            }.not_to change(franchise.reservations.first.payment.reload, :amount)
          end
        end
        context 'when coupon is applicable' do
          it 'adds coupon to reservation' do
            coupon = FactoryBot.create(:coupon, franchises: [franchise])
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            session[:cart] = [{ 'product_price_id' => product_price.id }]
            get :new
            post :new, params: { id: franchise.reservations.first.id, coupon: coupon.code }
            expect(franchise.reservations.first.payment.coupon).to eq(coupon)
          end
          it 'updates the reservation amount' do
            coupon = FactoryBot.create(:coupon, franchises: [franchise], percentage: true, value: 10)
            request.host = "#{franchise.slug}.lvh.me"
            session[:client_id] = client.id
            session[:cart] = [{ 'product_price_id' => product_price.id }]
            get :new

            post :new, params: { id: franchise.reservations.first.id, coupon: coupon.code }
            expect(franchise.reservations.first.payment.reload.amount).to eq(2700)
          end
        end
      end
    end
    it 'creates a reservation' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      session[:cart] = [{ 'product_price_id' => product_price.id }]
      get :new
      expect(franchise.reservations.count).to eq(1)
    end
    it 'creates payment instance' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      session[:cart] = [{ 'product_price_id' => product_price.id }]
      get :new
      expect(Payment.all.count).to eq(1)
      expect(Payment.last.amount).to eq(3000)
      expect(Payment.last.client).to eq(Reservation.last.client)
      expect(Reservation.last.payment).to eq(Payment.last)
      expect(Payment.last.transaction_id).not_to be_nil
      expect(Payment.last.product_name).to eq(Reservation.last.product_price.product.name)
    end
    context 'when cart has start time' do
      it 'creates a reservation with start time' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        session[:cart] = [{ 'product_price_id' => product_price.id, 'start_time' => '2021-01-01T08:00' }]
        get :new
        expect(franchise.reservations.count).to eq(1)
        expect(franchise.reservations.first.start_time).to eq('2021-01-01T08:00+01')
      end
    end
  end

  describe 'POST :callback' do
    let!(:payment) { FactoryBot.create(:payment) }
    let!(:reservation) { FactoryBot.create(:reservation, client: payment.client, payment: payment) }
    let(:params) do
      {
        vads_trans_id: payment.transaction_id,
        vads_amount: payment.amount,
      }
    end
    context 'when cart is empty' do
      it 'redirects to cart' do
        params[:vads_trans_status] = 'AUTHORISED'
        params[:vads_bank_label] = 'Société générale'
        get :callback, params: params
        expect(reservation.reload.paid?).to eq(false)
        expect(response).to redirect_to checkout_path
      end
    end
    context 'when vads_trans_status == AUTHORIZED' do
      it 'marks the reservation as paid' do
        session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
        params[:vads_bank_label] = 'Société générale'
        params[:vads_trans_status] = 'AUTHORISED'
        get :callback, params: params
        expect(reservation.payment.reload.successful?).to eq(true)
        expect(reservation.reload.paid?).to eq(true)
      end
    end
    context 'when vads_trans_status == ACCEPTED' do
      it 'marks the reservation as paid' do
        session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
        params[:vads_bank_label] = 'Société générale'
        params[:vads_trans_status] = 'ACCEPTED'
        get :callback, params: params
        expect(reservation.payment.reload.successful?).to eq(true)
        expect(reservation.reload.paid?).to eq(true)
      end
    end
    context 'when vads_trans_status is anything else' do
      it 'updates the paid status to failed' do
        session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]

        params[:vads_trans_status] = 'CANCELLED'
        get :callback, params: params
        expect(reservation.payment.reload.successful?).to eq(false)
        expect(reservation.reload.paid?).to eq(false)

        params[:vads_trans_status] = 'EXPIRED'
        get :callback, params: params
        expect(reservation.payment.reload.successful?).to eq(false)
        expect(reservation.reload.paid?).to eq(false)

        params[:vads_trans_status] = 'UNKNOWN'
        get :callback, params: params
        expect(reservation.payment.reload.successful?).to eq(false)
        expect(reservation.reload.paid?).to eq(false)

        params[:vads_trans_status] = 'azerty'
        get :callback, params: params
        expect(reservation.payment.reload.successful?).to eq(false)
        expect(reservation.reload.paid?).to eq(false)
      end
    end
    it 'saves bank name' do
      session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
      params[:vads_bank_label] = 'Société générale'
      params[:vads_trans_status] = 'AUTHORISED'
      get :callback, params: params
      expect(reservation.reload.payment.bank_name).to eq('Société générale')
    end
    it 'empties cart' do
      session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
      params[:vads_trans_status] = 'AUTHORISED'
      get :callback, params: params
      expect(session[:cart]).to be_nil
    end
    it 'does not create credit for client' do
      expect do
        session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
        params[:vads_trans_status] = 'AUTHORISED'
        get :callback, params: params
      end.not_to change(reservation.client.credits, :count)
    end
    context 'when product price is for multiple sessions' do
      it 'creates as many credits as session count' do
        reservation.product_price.update! session_count: 3
        expect {
          session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
          params[:vads_trans_status] = 'AUTHORISED'
          get :callback, params: params
        }.to change(reservation.client.credits, :count).by(3)
        expect(reservation.client.credits.count).to eq(3)
        expect(reservation.client.credits.pluck(:product_id).uniq).to eq([reservation.product_price.product.id])
      end
    end
    it 'sends invoice to client by email' do
      expect {
        session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
        params[:vads_trans_status] = 'AUTHORISED'
        get :callback, params: params
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
    it 'deletes all unpaid reservations for same client/product' do
      old_reservation = FactoryBot.create(:reservation, client: payment.client, product_price: reservation.product_price)
      old_reservation_2 = FactoryBot.create(:reservation, client: payment.client, product_price: reservation.product_price)
      expect {
        session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
        params[:vads_trans_status] = 'AUTHORISED'
        get :callback, params: params
      }.to change(Reservation, :count).by(-2)
      expect do
        old_reservation.reload
      end.to raise_error(ActiveRecord::RecordNotFound)
      expect do
        old_reservation_2.reload
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
