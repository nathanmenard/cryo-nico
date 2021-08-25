require 'rails_helper'

RSpec.describe SurveysController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
  let!(:product) { FactoryBot.create(:product, room: room) }
  let!(:survey_2) { FactoryBot.create(:survey) }
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
        xit 'returns all surveys from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: survey_2.franchise_id }
          expect(assigns(:surveys)).to eq([survey_2])
        end
      end
      it 'returns all surveys' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:surveys)).to eq(Survey.all)
      end
    end
    it 'returns all surveys of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:surveys)).to eq(current_user.franchise.surveys)
    end
  end

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { survey: { product_id: product.id, name: 'Q2 : Résultats' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { survey: { product_id: product.id, name: '' } }
        }.not_to change(current_user.franchise.surveys, :count)
      end
    end
    context 'when superuser' do
      xit 'creates survey for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { survey: { franchise_id: franchise_2.id, product_id: product.id, name: 'Q2 : Résultats' } }
        }.to change(franchise_2.surveys, :count).by(1)
        expect(Survey.last.name).to eq('Q2 : Résultats')
        expect(Survey.last.product).to eq(product)
      end
    end
    it 'creates survey' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { survey: { product_id: product.id, name: 'Q2 : Résultats' } }
      }.to change(product.surveys, :count).by(1)
      expect(Survey.last.name).to eq('Q2 : Résultats')
    end
  end

  describe 'PUT :update' do
    let!(:survey) { FactoryBot.create(:survey, product: product) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: survey.id, survey: { name: 'Q3: ..' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: survey.id, survey: { name: '' } }
        }.not_to change(current_user.franchise.surveys, :count)
      end
    end
    context 'when superuser' do
      xit 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: survey.id, survey: { franchise_id: franchise_2.id, name: 'Q3 : ...' } }
        }.to change(current_user.franchise.surveys, :count).by(-1)
        expect(survey.reload.product).to eq(product_2)
        expect(survey.reload.name).to eq('Q3 : ...')
      end
    end
    it 'updates survey' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: survey.id, survey: { name: 'Q3 : ...' } }
      }.not_to change(product.surveys, :count)
      expect(survey.reload.name).to eq('Q3 : ...')
    end
  end

  describe 'GET :show' do
    let!(:survey) { FactoryBot.create(:survey, product: product) }
    let!(:survey_2) { FactoryBot.create(:survey) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: survey.id }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when not found' do
      it 'displays 404' do
        session[:user_id] = current_user.id
        get :show, params: { id: 0 }
        expect(response.status).to eq(404)
      end
    end
    context 'when superuser' do
      context 'when survey from another franchise' do
        it 'renders survey page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: survey_2.id }
          expect(assigns(:survey)).to eq(survey_2)
        end
      end
    end
    it 'renders survey page' do
      session[:user_id] = current_user.id
      get :show, params: { id: survey.id }
      expect(assigns(:survey)).to eq(survey)
    end
  end

  describe 'DELETE :destroy' do
    let!(:survey) { FactoryBot.create(:survey, product: product) }
    let!(:survey_2) { FactoryBot.create(:survey) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: survey.id }
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
      context 'when survey from another franchise' do
       xit 'deletes survey' do
          current_user.update superuser: true
          expect {
            session[:user_id] = current_user.id
            delete :destroy, params: { id: survey_2.id }
          }.to change(survey_2.franchise.surveys, :count).by(-1)
        end
      end
    end
    it 'deletes survey' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: survey.id }
      }.to change(current_user.franchise.surveys, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: survey.id }
      expect(response.status).to eq(204)
    end
  end
end
