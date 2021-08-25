require 'rails_helper'

RSpec.describe ExternalProductsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:external_product_2) { FactoryBot.create(:external_product) }
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
        it 'returns all external_products from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: external_product_2.franchise_id }
          expect(assigns(:external_products)).to eq([external_product_2])
        end
      end
      it 'returns all external_products' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:external_products)).to eq(ExternalProduct.all)
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
    it 'returns all external_products of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:external_products)).to eq(current_user.franchise.external_products)
    end
  end

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { external_product: { name: 'Mon produit', amount: '30', tax_rate: '20' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
        post :create, params: { external_product: { name: 'Mon produit', amount: '30' } }
        }.not_to change(current_user.franchise.external_products, :count)
      end
    end
    context 'when superuser' do
      it 'creates external_product for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { external_product: { franchise_id: franchise_2.id, name: 'Mon produit', amount: '30', tax_rate: '20' } }
        }.to change(franchise_2.external_products, :count).by(1)
        expect(ExternalProduct.last.name).to eq('Mon produit')
        expect(ExternalProduct.last.amount).to eq(30)
        expect(ExternalProduct.last.tax_rate).to eq(20)
      end
    end
    it 'creates external_product' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { external_product: { name: 'Mon produit', amount: '30', tax_rate: '20' } }
      }.to change(current_user.franchise.external_products, :count).by(1)
      expect(ExternalProduct.last.name).to eq('Mon produit')
      expect(ExternalProduct.last.amount).to eq(30)
      expect(ExternalProduct.last.tax_rate).to eq(20)
    end
  end

  describe 'PUT :update' do
    let!(:external_product) { FactoryBot.create(:external_product, franchise: current_user.franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: external_product.id, external_product: { tax_rate: '5.5' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
        put :update, params: { id: external_product.id, external_product: { tax_rate: '' } }
        }.not_to change(current_user.franchise.external_products, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: external_product.id, external_product: { franchise_id: franchise_2.id, tax_rate: '5.5' } }
        }.to change(current_user.franchise.external_products, :count).by(-1)
        expect(external_product.reload.franchise).to eq(franchise_2)
        expect(external_product.reload.tax_rate).to eq(5.5)
      end
    end
    it 'updates external_product' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: external_product.id, external_product: { tax_rate: '5.5' } }
      }.not_to change(current_user.franchise.external_products, :count)
      expect(external_product.reload.tax_rate).to eq(5.5)
    end
  end

  describe 'DELETE :destroy' do
    let!(:external_product) { FactoryBot.create(:external_product, franchise: current_user.franchise) }
    let!(:external_product_2) { FactoryBot.create(:external_product) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: external_product.id }
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
    context 'when superuser' do
      context 'when external_product from another franchise' do
        it 'deletes external_product' do
          current_user.update superuser: true
          expect {
            session[:user_id] = current_user.id
            delete :destroy, params: { id: external_product_2.id }
          }.to change(external_product_2.franchise.external_products, :count).by(-1)
        end
      end
    end
    it 'deletes external_product' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: external_product.id }
      }.to change(current_user.franchise.external_products, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: external_product.id }
      expect(response.status).to eq(204)
    end
  end
end
