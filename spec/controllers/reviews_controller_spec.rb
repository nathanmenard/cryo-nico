require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:review_2) { FactoryBot.create(:review) }
  let(:franchise_2) { FactoryBot.create(:franchise) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login form' do
        get :index
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when superuser' do
      context 'when filter by franchise' do
        it 'returns all reviews from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: review_2.product.room.franchise_id }
          expect(assigns(:reviews)).to eq([review_2])
        end
      end
      it 'returns all reviews' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:reviews)).to eq(Review.all.order(id: :desc))
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
    it 'returns all reviews of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:reviews)).to eq(current_user.franchise.reviews.order(id: :desc))
    end
  end

  describe 'PUT /:id' do
    let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let!(:review) { FactoryBot.create(:review, product: product) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: review.id, review: { published: 'true' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: review.id, review: { published: '' } }
        }.not_to change(review.reload, :published)
      end
    end
    context 'when superuser' do
      it 'updates published flag' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: review.id, review: { published: 'false' } }
        }.not_to change(current_user.franchise.reviews, :count)
        expect(review.reload.published).to eq(false)
      end
    end
    it 'updates review' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: review.id, review: { published: 'true' } }
      }.not_to change(current_user.franchise.reviews, :count)
      expect(review.reload.published).to eq(true)
    end
  end

  describe 'GET /mon_avis' do
    let(:franchise) { FactoryBot.create(:franchise) }
    context 'when reservation not found' do
      it 'returns 404' do
        request.host = "#{franchise.slug}.lvh.me"
        get :new, params: { key: 'unknown' }
        expect(response.status).to eq(404)
      end
    end
    context 'when reservation found' do
      it 'displays form' do
        room = FactoryBot.create(:room, franchise: franchise)
        product = FactoryBot.create(:product, room: room)
        product_price = FactoryBot.create(:product_price, product: product)
        reservation = FactoryBot.create(:reservation, product_price: product_price)
        request.host = "#{franchise.slug}.lvh.me"
        get :new, params: { key: reservation.private_key }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST /mon_avis' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:room) { FactoryBot.create(:room, franchise: franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    context 'when invalid payload' do
      it 'does not create review' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :create, params: { key: reservation.private_key, body: '' }
        }.not_to change(product.reviews, :count)
      end
      it 'displays error' do
        request.host = "#{franchise.slug}.lvh.me"
        post :create, params: { key: reservation.private_key, body: '' }
        expect(assigns(:success)).to eq(false)
      end
    end
    context 'when reservation found' do
      it 'creates review' do
        expect {
          request.host = "#{franchise.slug}.lvh.me"
          post :create, params: { key: reservation.private_key, body: 'Excellent!' }
        }.to change(product.reviews, :count).by(1)
        expect(Review.last.client).to eq(reservation.client)
        expect(Review.last.body).to eq('Excellent!')
        expect(Review.last.published).to eq(nil)
      end
      it 'displays success message' do
        request.host = "#{franchise.slug}.lvh.me"
        post :create, params: { key: reservation.private_key, body: 'Excellent!' }
        expect(assigns(:success)).to eq(true)
      end
    end
  end
end
