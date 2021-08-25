require 'rails_helper'

RSpec.describe CreditsController, type: :controller do
  let(:franchise)   { FactoryBot.create(:franchise) }
  let(:client)      { FactoryBot.create(:client, franchise: franchise) }
  let(:reservation) { FactoryBot.create(:reservation, client: client) }
  let!(:credit)      { FactoryBot.create(:credit, product: reservation.product_price.product, client: client) }

  describe 'GET :index' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
    it 'renders view 'do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        get :index
        expect(response).to render_template(:index)
    end
  end

  describe 'DESTROY :delete' do
    context 'when not logged in' do
      it 'redirects to login page' do
        request.host = "#{franchise.slug}.lvh.me"
        delete :destroy, params: { id: credit.id, credit: { reservation_id: reservation.id } }
        expect(response).to redirect_to(login_path)
      end
    end
    context 'when empty cart' do
      it 'redirects to root' do
        request.host = "#{franchise.slug}.lvh.me"
        session[:client_id] = client.id
        delete :destroy, params: { id: credit.id, credit: { reservation_id: reservation.id } }
        expect(response).to redirect_to(root_path)
      end
    end
    it 'empties cart' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
      delete :destroy, params: { id: credit.id, credit: { reservation_id: reservation.id } }
      expect(session[:cart]).to be_nil
    end
    it 'deletes credit' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
      expect {
        delete :destroy, params: { id: credit.id, credit: { reservation_id: reservation.id } }
      }.to change(client.credits.all, :count).by(-1)
    end
    it 'marks reservation as paid by credit' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
      delete :destroy, params: { id: credit.id, credit: { reservation_id: reservation.id } }
      expect(reservation.reload.paid_by_credit).to eq(true)
    end
    it 'redirects to edit reservation form' do
      request.host = "#{franchise.slug}.lvh.me"
      session[:client_id] = client.id
      session[:cart] = [{ 'product_price_id' => reservation.product_price.id }]
      delete :destroy, params: { id: credit.id, credit: { reservation_id: reservation.id } }
      expect(response).to redirect_to("/reservations/#{reservation.id}")
    end
  end
end
