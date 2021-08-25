require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET /prestations/:slug' do
    let(:product) { FactoryBot.create(:product) }
    let!(:product_price) { FactoryBot.create(:product_price, product: product, session_count: 1, professionnal: false) }
    let!(:product_price_first_time) { FactoryBot.create(:product_price, product: product, session_count: 1, professionnal: false, first_time: true) }
    let(:client) { FactoryBot.create(:client, franchise: product.room.franchise) }
    context 'when not logged in' do
      it' redirects to login form' do
        request.host = "#{product.room.franchise.slug}.lvh.me"
        get :product, params: { slug: product.slug }
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when product does not exist for current franchise' do
      it 'renders 404' do
        product_2 = FactoryBot.create(:product)
        request.host = "#{product.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :product, params: { slug: product_2.slug }
        expect(response.status).to eq(404);
      end
    end
    context 'when product exists for current franchise' do
      it 'renders product page' do
        request.host = "#{product.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :product, params: { slug: product.slug }
        expect(assigns(:product)).to eq(product)
      end
    end
    context 'when product.slug == nutrition' do
      it 'renders nutrition form' do
        nutrition = FactoryBot.create(:product, name: 'Nutrition')
        request.host = "#{nutrition.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :product, params: { slug: nutrition.slug }
        expect(response).to render_template(:nutrition)
      end
    end
    context 'when start_from param' do
      context 'when start_from is in the past' do
        it 'sets start_from = Date.tomorrow' do
          Timecop.freeze(2021, 1, 1) do
            request.host = "#{product.room.franchise.slug}.lvh.me"
            session[:client_id] = client.id
            get :product, params: { slug: product.slug, start_from: '2021-01-01' }
            expect(assigns(:dates)).to eq([Date.today, Date.today+1.day, Date.today+3.days, Date.today+4.days])
          end
        end
      end
      it 'assigns @dates (4 days starting from params[:start-from]' do
        request.host = "#{product.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        allow(Date).to receive(:today).and_return Date.new(2020, 01, 01)
        get :product, params: { slug: product.slug, start_from: '2021-01-01' }
        expect(assigns(:dates)).to eq([Date.parse('2021-01-01'), Date.parse('2021-01-02'), Date.parse('2021-01-04'), Date.parse('2021-01-05')]) # skipping sunday
      end
    end
    context 'when no date param' do
      it 'assigns @dates (4 days starting from tomorrow)' do
        Timecop.freeze(2021, 1, 1) do
          request.host = "#{product.room.franchise.slug}.lvh.me"
          session[:client_id] = client.id
          get :product, params: { slug: product.slug }
          expect(assigns(:dates)).to eq([Date.tomorrow, Date.tomorrow+2.days, Date.tomorrow+3.days, Date.tomorrow+4.days])
        end
      end
    end
    context 'when current client has already bought current product' do
      let(:payment) { FactoryBot.create(:payment, :successful, client: client, product_name: product.name) }
      let!(:reservation) { FactoryBot.create(:reservation, client: client, product_price: product_price, payment: payment) }
      it 'defaults to @product_price.session_count = 1' do
        request.host = "#{product.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :product, params: { slug: product.slug }
        expect(assigns(:product_price)).to eq(product_price)
      end
    end
    context 'when current client has already bought current product' do
      it 'defaults to @product_price.session_count = 1 & @product_price.first_time = true' do
        request.host = "#{product.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :product, params: { slug: product.slug }
        expect(assigns(:product_price)).to eq(product_price_first_time)
      end
    end
  end

  describe 'POST /contact' do
    let(:franchise) { FactoryBot.create(:franchise, email: 'hello@gmail.com') }
    it 'sends an email to the franchise' do
      expect {
        request.host = "#{franchise.slug}.lvh.me"
        post :contact, params: { first_name: 'Saïd', last_name: 'Mimouni', email: 'said@gmail.com', subject: 'Hello', message: 'Hello World!' }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
      expect(ActionMailer::Base.deliveries.first.to).to eq([franchise.email])
      expect(ActionMailer::Base.deliveries.first.reply_to).to eq(['said@gmail.com'])
      expect(ActionMailer::Base.deliveries.first.subject).to eq('Hello')
      expect(ActionMailer::Base.deliveries.first.body.decoded).to eq('Hello World!')
    end
    context 'when type == nutrition' do
      let!(:nutritionist) { FactoryBot.create(:user, franchise: franchise, nutritionist: true, email: 'nutrionist@gmail.com') }
      it 'sends email to nutritionist as well' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :contact, params: { type: 'Nutrition', first_name: 'Saïd', last_name: 'Mimouni', email: 'said@gmail.com', subject: 'Hello', message: 'Hello World!' }
        }.to change(ActionMailer::Base.deliveries, :count).by(2)
        expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
        expect(ActionMailer::Base.deliveries.first.to).to eq([franchise.email])
        expect(ActionMailer::Base.deliveries.first.reply_to).to eq(['said@gmail.com'])
        expect(ActionMailer::Base.deliveries.first.subject).to eq('Hello')
        expect(ActionMailer::Base.deliveries.first.body.decoded).to eq('Hello World!')
        expect(ActionMailer::Base.deliveries.last.from).to eq(['contact@cryotera.fr'])
        expect(ActionMailer::Base.deliveries.last.to).to eq(['nutrionist@gmail.com'])
        expect(ActionMailer::Base.deliveries.last.reply_to).to eq(['said@gmail.com'])
        expect(ActionMailer::Base.deliveries.last.subject).to eq('Hello')
        expect(ActionMailer::Base.deliveries.second.body.decoded).to eq('Hello World!')
      end
    end
    it 'displays success message' do
      request.host = "#{franchise.slug}.lvh.me"
      post :contact, params: { first_name: 'Saïd', last_name: 'Mimouni', email: 'said@gmail.com', subject: 'Hello', message: 'Hello World!' }
      expect(assigns(:success)).to eq(true)
    end
  end

  describe' POST /cart/items' do
    let(:product_price) { FactoryBot.create(:product_price) }
    context 'when product already in cart' do
      it 'does not add product to cart' do
        request.host = "#{product_price.product.room.franchise.slug}.lvh.me"
        session[:cart] = [{
          product_price_id: product_price.id.to_s,
        }]
        post :add_to_cart, params: { product_price_id: product_price.id }
        expect(session[:cart]).to eq([{
          product_price_id: product_price.id.to_s,
        }])
      end
    end
    it 'adds product to cart' do
      request.host = "#{product_price.product.room.franchise.slug}.lvh.me"
      post :add_to_cart, params: { product_price_id: product_price.id }
      expect(session[:cart]).to eq([{
        product_price_id: product_price.id.to_s,
        start_time: nil,
      }])
    end
    context 'when start time param' do
      it 'adds start time to cart' do
        request.host = "#{product_price.product.room.franchise.slug}.lvh.me"
        post :add_to_cart, params: { product_price_id: product_price.id, start_time: '2021-01-01T08:00' }
        expect(session[:cart]).to eq([{
          product_price_id: product_price.id.to_s,
          start_time: '2021-01-01T08:00',
        }])
      end
    end
  end

  describe 'POST /checkout/:reservation_id/times' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:room) { FactoryBot.create(:room, franchise: franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    context 'when given date param' do
      it 'updates reservation start time (only date)' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = reservation.client.id
        current_datetime = '2021-01-01T08:22'
        post :checkout_times, params: { reservation_id: reservation.id, date: current_datetime }
        expect(reservation.reload.start_time).to eq('2021-01-01T09:30+01')
      end
    end
    context 'when given hour & minutes param' do
      it 'updates reservation start time (hour & minutes)' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = reservation.client.id
        current_date = '2020-01-01'
        post :checkout_times, params: { reservation_id: reservation.id, date: current_date }
        expect(reservation.reload.start_time.strftime('%Y-%m-%d')).to eq(current_date)

        post :checkout_times, params: { reservation_id: reservation.id, hour: '10', minutes: '30' }
        expect(reservation.reload.start_time.strftime('%Y-%m-%d')).to eq(current_date)
        expect(reservation.reload.start_time.strftime('%H:%M')).to eq('10:30')
      end
    end
  end

  describe 'GET /parrainage' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:client) { FactoryBot.create(:client, franchise: franchise) }
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :sponsorship
        expect(response).to redirect_to(login_path)
      end
    end
    it 'assigns @clients' do
      client_2 = FactoryBot.create(:client, franchise: franchise, client: client)
      FactoryBot.create(:client, franchise: franchise)
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      get :sponsorship
      expect(assigns(:clients)).to eq([client_2])
    end
  end

  describe 'POST /parrainage' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:client) { FactoryBot.create(:client, franchise: franchise) }
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        post :sponsorship, params: { email: 'hello@gmail.com' }
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when email already belongs to a client' do
      it 'does not send email' do
        client_2 = FactoryBot.create(:client, franchise: franchise)
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          session[:client_id] = client.id
          post :sponsorship, params: { email: client_2.email }
        }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
    it 'sends invite email' do
      expect {
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        post :sponsorship, params: { email: 'hello@gmail.com' }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
      expect(ActionMailer::Base.deliveries.first.to).to eq(['hello@gmail.com'])
      expect(ActionMailer::Base.deliveries.first.subject).to eq('Saïd MIMOUNI vous invite à rejoindre Cryotera !')
      expect(ActionMailer::Base.deliveries.first.body.decoded).to include('Saïd MIMOUNI vous invite à rejoindre le centre Cryotera')
    end
    it 'redirects back' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      post :sponsorship, params: { email: 'hello@gmail.com' }
      expect(response).to redirect_to(sponsorship_path)
    end
  end

  describe 'GET :edit_reservation' do
    let(:franchise) { FactoryBot.create(:franchise, banking_secret_id: 'abc', banking_secret_key: 'foo') }
    let(:client) { FactoryBot.create(:client, franchise: franchise) }
    let(:room) { FactoryBot.create(:room, franchise: franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let!(:reservation) { FactoryBot.create(:reservation, client: client, product_price: product_price) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :edit_reservation, params: { id: reservation.id }
        expect(response).to redirect_to('/login')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:client_id] = client.id
        get :edit_reservation, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when does not belong to current client' do
      it 'displays 404' do
        reservation.update(client: FactoryBot.create(:client))
        session[:client_id] = client.id
        get :edit_reservation, params: { id: reservation.id }
        expect(response.status).to eq(404)
      end
    end
    context 'when start_from param' do
      context 'when start_from is in the past' do
        it 'sets start_from = Date.tomorrow' do
          Timecop.freeze(2021, 1, 1) do
            request.host = "#{product.room.franchise.slug}.lvh.me"
            session[:client_id] = client.id
            get :edit_reservation, params: { id: reservation.id, start_from: '2021-01-02' }
            expect(assigns(:dates)).to eq([Date.tomorrow, Date.tomorrow+2.days, Date.tomorrow+3.days, Date.tomorrow+4.days])
          end
        end
      end
      it 'assigns @dates (4 days starting from params[:start-from]' do
        request.host = "#{product.room.franchise.slug}.lvh.me"
        session[:client_id] = client.id
        allow(Date).to receive(:today).and_return Date.new(2020, 01, 01)
        get :edit_reservation, params: { id: reservation.id, start_from: '2021-01-01' }
        expect(assigns(:dates)).to eq([Date.parse('2021-01-01'), Date.parse('2021-01-02'), Date.parse('2021-01-04'), Date.parse('2021-01-05')]) # skipping sunday
      end
    end
    context 'when no date param' do
      it 'assigns @dates (4 days starting from tomorrow)' do
        Timecop.freeze(2021, 1, 1) do
          request.host = "#{product.room.franchise.slug}.lvh.me"
          session[:client_id] = client.id
          get :edit_reservation, params: { id: reservation.id }
          expect(assigns(:dates)).to eq([Date.tomorrow, Date.tomorrow+2.days, Date.tomorrow+3.days, Date.tomorrow+4.days])
        end
      end
    end
    it 'assigns @reservation' do
      session[:client_id] = client.id
      get :edit_reservation, params: { id: reservation.id }
      expect(assigns(:reservation)).to eq(reservation)
    end
  end

  describe 'DELETE /reservations/:id' do
    let(:franchise) { FactoryBot.create(:franchise, banking_secret_id: 'abc', banking_secret_key: 'foo') }
    let(:client) { FactoryBot.create(:client, franchise: franchise) }
    let(:room) { FactoryBot.create(:room, franchise: franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let!(:reservation) { FactoryBot.create(:reservation, client: client, product_price: product_price) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :cancel_reservation, params: { id: reservation.id }
        expect(response).to redirect_to('/login')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:client_id] = client.id
        delete :cancel_reservation, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when does not belong to current client' do
      it 'displays 404' do
        reservation.update(client: FactoryBot.create(:client))
        session[:client_id] = client.id
        delete :cancel_reservation, params: { id: reservation.id }
        expect(response.status).to eq(404)
      end
    end
    it 'marks reservation as canceled' do
      expect {
        session[:client_id] = client.id
        delete :cancel_reservation, params: { id: reservation.id }
      }.not_to change(client.reservations, :count)
      expect(reservation.reload.canceled).to eq(true)
      expect(reservation.reload.cancelation_reason).to eq('canceled_by_client')
    end
    it 'refunds client' do
      expect {
        session[:client_id] = client.id
        delete :cancel_reservation, params: { id: reservation.id }
      }.to change(Payment, :count).by(1)
    end
    it 'returns 204' do
      session[:client_id] = client.id
      delete :cancel_reservation, params: { id: reservation.id }
      expect(response.status).to eq(204)
    end
  end

  describe 'GET :payments' do
    context 'when not logged in' do
      it 'redirects to login form'
    end
    context 'when company client' do
      it 'returns payments'
    end
    context 'when client' do
      it 'returns payments'
    end
  end
end
