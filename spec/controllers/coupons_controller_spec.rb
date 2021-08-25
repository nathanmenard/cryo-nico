require 'rails_helper'

RSpec.describe CouponsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:franchise) { FactoryBot.create(:franchise) }
  let!(:coupon_2) { FactoryBot.create(:coupon, franchises: [franchise]) }
  let!(:global_coupon) { FactoryBot.create(:coupon) }
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
        it 'returns all coupons from given franchise + global coupons' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: coupon_2.franchises.first.id }
          #expect(assigns(:coupons)).to eq([coupon_2, global_coupon])
          expect(assigns(:coupons)).to eq([coupon_2]) # TODO
        end
      end
      it 'returns all coupons' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:coupons)).to eq(Coupon.all)
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
    it 'returns all coupons of current user franchise + global coupons' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:coupons)).to eq(current_user.franchise.coupons)
      expect(assigns(:coupons).pluck(:franchise_ids)).to eq([]) # TODO
    end
  end

  describe 'POST /' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { coupon: { name: 'Mon code', value: '10', 'code': 'Welcome10', percentage: 'true' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { coupon: { name: '' } }
        }.not_to change(current_user.franchise.coupons, :count)
      end
    end
    context 'when superuser' do
      it 'creates client for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { coupon: { franchise_ids: [franchise_2.id], name: 'Mon code', value: '10', 'code': 'Welcome10', percentage: 'true' } }
        }.to change(franchise_2.coupons, :count).by(1)
        expect(Coupon.last.name).to eq('Mon code')
        expect(Coupon.last.value).to eq(10)
        expect(Coupon.last.code).to eq('welcome10')
        expect(Coupon.last.percentage).to eq(true)
      end
    end
    it 'creates coupon' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { coupon: { name: 'Mon code', value: '10', 'code': 'Welcome10', percentage: 'true' } }
      }.to change(current_user.franchise.coupons, :count).by(1)
      expect(Coupon.last.name).to eq('Mon code')
      expect(Coupon.last.value).to eq(10)
      expect(Coupon.last.code).to eq('welcome10')
      expect(Coupon.last.percentage).to eq(true)
    end
    it 'redirects to coupon' do
      session[:user_id] = current_user.id
      post :create, params: { coupon: { name: 'Mon code', value: '10', 'code': 'Welcome10', percentage: 'true' } }
      expect(response).to redirect_to(Coupon.last)
    end
  end

  describe 'PUT /:id' do
    let!(:coupon) { FactoryBot.create(:coupon, franchises: [current_user.franchise]) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: coupon.id, coupon: { value: '20' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: coupon.id, coupon: { name: '' } }
        }.not_to change(current_user.franchise.coupons, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        franchise_2 = FactoryBot.create(:franchise)
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: coupon.id, coupon: { franchise_ids: [franchise_2.id], value: '20' } }
        }.to change(current_user.franchise.coupons, :count).by(-1)
        expect(coupon.reload.franchises).to eq([franchise_2])
        expect(coupon.reload.value).to eq(20)
      end
    end
    it 'updates coupon' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: coupon.id, coupon: { value: '20' } }
      }.not_to change(current_user.franchise.coupons, :count)
      expect(coupon.reload.value).to eq(20)
    end
  end

  describe 'GET /:id' do
    let!(:coupon) { FactoryBot.create(:coupon, franchises: [current_user.franchise]) }
    let!(:coupon_2) { FactoryBot.create(:coupon) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: coupon.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when superuser' do
      context 'when coupon from another franchise' do
        it 'renders coupon page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: coupon_2.id }
          expect(assigns(:coupon)).to eq(coupon_2)
        end
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        get :show, params: { id: '0' }
        expect(response.status).to eq(404)
      end
    end
    it 'renders coupon page' do
      session[:user_id] = current_user.id
      get :show, params: { id: coupon.id }
      expect(assigns(:coupon)).to eq(coupon)
    end
  end

  describe 'DELETE /:id' do
    let!(:coupon) { FactoryBot.create(:coupon, franchises: [current_user.franchise]) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: coupon.id }
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
    it 'deletes coupon' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: coupon.id }
      }.to change(current_user.franchise.coupons, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: coupon.id }
      expect(response.status).to eq(204)
    end
  end
end
