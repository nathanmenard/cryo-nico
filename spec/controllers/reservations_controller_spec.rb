require 'rails_helper'

RSpec.describe ReservationsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:client) { FactoryBot.create(:client, franchise: current_user.franchise) }
  let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
  let(:product) { FactoryBot.create(:product, room: room) }
  let!(:product_price) { FactoryBot.create(:product_price, product: product) }
  let!(:reservation_2) { FactoryBot.create(:reservation) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to('/admin')
      end
    end
    context 'superuser' do
      context 'when filter by franchise' do
        xit 'returns all reservations from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: reservation_2.product_price.product.room.franchise_id }
          expect(assigns(:reservations)).to eq([reservation_2])
        end
      end
    end
    context 'nutritionist' do
      let!(:nutrition_room) { FactoryBot.create(:room, franchise: current_user.franchise) }
      let!(:nutrition) { FactoryBot.create(:product, room: nutrition_room, name: 'Nutrition') }
      let!(:nutrition_product_price) { FactoryBot.create(:product_price, product: nutrition) }
      it 'assigns @room::nutrition only' do
        current_user.update nutritionist: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:rooms)).to eq([nutrition_room])
      end
      it 'assigns @product::nutrition only' do
        current_user.update nutritionist: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:products)).to eq([nutrition])
      end
    end
    it 'assigns @rooms with rooms with products' do
      FactoryBot.create(:room, franchise: current_user.franchise)
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:rooms)).to eq([room])
    end
    it 'assigns @products with products with unit pricing at least' do
      product_b = FactoryBot.create(:product, room: room)
      FactoryBot.create(:product_price, product: product_b, session_count: 1, professionnal: true)
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:products)).to eq([product])
    end
    context 'when date param' do
      it 'assigns @reservations (does not include canceled reservations) for given date' do
        reservation_a = FactoryBot.create(:reservation, product_price: product_price, start_time: Date.today)
        reservation_b = FactoryBot.create(:reservation, product_price: product_price, start_time: Date.today - 1.day)

        session[:user_id] = current_user.id
        get :index, params: { date: Date.yesterday.to_s }
        expect(assigns(:reservations)).to eq([reservation_b])

        get :index, params: { date: Date.today.to_s }
        expect(assigns(:reservations)).to eq([reservation_a])
      end
    end
    it 'assigns @reservations (does not include canceled reservations)' do
      reservation = FactoryBot.create(:reservation, product_price: product_price, client: client, start_time: Date.today)
      canceled_reservation = FactoryBot.create(:reservation, product_price: product_price, client: client, canceled: true, start_time: Date.today)
      reservation_tomorrow = FactoryBot.create(:reservation, product_price: product_price, client: client, start_time: Date.today+1.day)
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:reservations)).to eq([reservation])
    end
    it 'assigns @blockers' do
      blocker_a = FactoryBot.create(:blocker, franchise: current_user.franchise, start_time: Date.today)
      blocker_b = FactoryBot.create(:blocker, franchise: current_user.franchise, start_time: Date.today + 1.day)
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:blockers)).to eq([blocker_a])
    end
    it 'assigns @date' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:date)).to eq(Date.today)
    end
  end

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00', email_notification: '1' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays error as json' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { reservation: { client_id: client.id, product_id: product.id } }
        }.not_to change(current_user.franchise.reservations, :count)
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['error']).not_to eq(nil)
      end
    end
    context 'when not enough capacity in the room' do
      it 'returns error' do
        session[:user_id] = current_user.id

        # room capacity = 4 (since we are admin, capacity for us becomes 5)
        5.times do |x|
          expect do
            post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00',  email_notification: '1' } }
          end.to change(current_user.franchise.reservations, :count).by(1)
          expect(response.status).to eq(302)
        end

        expect do
          post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00',  email_notification: '1' } }
        end.not_to change(current_user.franchise.reservations, :count)
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)['error']).to eq('INVALID_CAPACITY')
      end
    end
    it 'creates reservation' do
      expect(current_user.franchise.reservations.count).to eq(0)
      session[:user_id] = current_user.id
      post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00',  email_notification: '1' } }
      expect(current_user.franchise.reservations.count).to eq(1)
      expect(Reservation.last.client).to eq(client)
      expect(Reservation.last.product_price).to eq(product_price)
      expect(Reservation.last.start_time).to eq('2020-01-01T:09:00+01')
      expect(Reservation.last.first_time).to eq(true)
      expect(Reservation.last.email_notification).to eq(true)
      expect(Reservation.last.paid?).to eq(false)
      expect(Reservation.last.user).to eq(current_user)
      expect(Reservation.last.to_be_paid_online).to eq(false)
    end
    context 'when no credit' do
      it 'creates payment' do
        expect(Payment.count).to eq(0)
        session[:user_id] = current_user.id
        post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00', email_notification: '1' } }
        expect(Payment.count).to eq(1)
        expect(Payment.last.client).to eq(Reservation.last.client)
        expect(Payment.last.amount).to eq(product_price.total * 100)
        expect(Payment.last.mode).to eq(nil)
        expect(Payment.last.product_name).to eq(product.name)
        expect(Reservation.last.payment).to eq(Payment.last)
      end
    end
    context 'when has credit' do
      it 'removes credit' do
        2.times do
          FactoryBot.create(:credit, client: client, product: product)
        end
        expect do
          session[:user_id] = current_user.id
          post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00', email_notification: '1' } }
        end.to change(client.credits, :count).by(-1)
        expect(Payment.count).to eq(0)
      end
    end
    context 'when @reservation.email.notification == false' do
      it 'does not try to send email' do
        expect {
          session[:user_id] = current_user.id
          client.update email: 'hello@gmail.com'
          post :create, params: { reservation: { client_id: client.id, productid: product.id, start_time: '2020-01-01T:09:00', email_notification: '0' } }
        }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
    context 'when @reservation.email.notification == true' do
      it 'sends email to client' do
        expect {
          session[:user_id] = current_user.id
          client.update email: 'hello@gmail.com'
          post :create, params: { reservation: { client_id: client.id, product_id: product.id, start_time: '2020-01-01T:09:00', email_notification: '1' } }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end

  describe 'PUT :update' do
    let!(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: reservation.id, reservation: { start_time: '2020-01-01T10:00' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: reservation.id, reservation: { name: '' } }
        }.not_to change(current_user.franchise.reservations, :count)
      end
    end
    it 'updates reservation' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: reservation.id, reservation: { start_time: '2020-01-01T10:00' } }
      }.not_to change(current_user.franchise.reservations, :count)
      expect(reservation.reload.start_time).to eq('2020-01-01T10:00+01')
    end
    context 'when cancelation_reason & perform_refund params' do
      context 'when perform_refund == false' do
        it 'does not create credit for client' do
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: reservation.id, reservation: { cancelation_reason: 'did_not_come', perform_refund: 'false' } }
          }.not_to change(reservation.client.credits, :count)
          expect(reservation.reload.cancelation_reason).to eq('did_not_come')
          expect(reservation.reload.refunded).to eq(false)
        end
      end
      context 'when perform_refund == credit' do
        it 'creates credit for client' do
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: reservation.id, reservation: { cancelation_reason: 'did_not_come', perform_refund: 'credit' } }
          }.to change(reservation.client.credits, :count).by(1)
          expect(reservation.reload.cancelation_reason).to eq('did_not_come')
          expect(reservation.reload.refunded).to eq(true)
        end
        it 'does not create payment' do
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: reservation.id, reservation: { cancelation_reason: 'did_not_come', perform_refund: 'credit' } }
          }.not_to change(Payment, :count)
        end
      end
      context 'when perform_refund == money' do
        it 'does not create credit for client' do
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: reservation.id, reservation: { cancelation_reason: 'did_not_come', perform_refund: 'money' } }
          }.not_to change(reservation.client.credits, :count)
        end
        it 'creates payment' do
          expect {
            session[:user_id] = current_user.id
            put :update, params: { id: reservation.id, reservation: { cancelation_reason: 'did_not_come', perform_refund: 'money' } }
          }.to change(Payment, :count).by(1)
          expect(Payment.last.client).to eq(reservation.client)
          expect(Payment.last.amount).to eq(-reservation.product_price.product.product_prices.find_by(session_count: 1, professionnal: false).total*100)
          expect(Payment.last.product_name).to eq(reservation.product_price.product.name)
          expect(Payment.last.as_paid).to eq(true)
        end
      end
      it 'sets reservation#canceled = true' do
        session[:user_id] = current_user.id
        put :update, params: { id: reservation.id, reservation: { cancelation_reason: 'did_not_come', perform_refund: 'credit' } }
        expect(reservation.reload.canceled).to eq(true)
        expect(reservation.reload.cancelation_reason).to eq('did_not_come')
      end
    end
  end

  describe 'GET :sign' do
    let!(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :sign, params: { id: reservation.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        get :sign, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when not first time' do
      it 'displays 404' do
        reservation.update first_time: false
        session[:user_id] = current_user.id
        get :sign, params: { id: reservation.id }
        expect(response.status).to eq(404)
      end
    end
    context 'when superuser' do
      context 'when user from another franchise' do
        it 'assigns @reservation' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :sign, params: { id: reservation_2.id }
          expect(assigns(:reservation)).to eq(reservation_2)
        end
      end
    end
    context 'when already signed' do
      it 'assigns @reservation' do
        reservation.update(first_time: true, signature: '{"foo": "bar"}')
        session[:user_id] = current_user.id
        get :sign, params: { id: reservation.id }
        expect(assigns(:reservation)).to eq(reservation)
      end
    end
    it 'assigns @reservation' do
      session[:user_id] = current_user.id
      get :sign, params: { id: reservation.id }
      expect(assigns(:reservation)).to eq(reservation)
    end
  end
end
