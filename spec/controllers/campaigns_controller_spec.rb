require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let!(:campaign_template) { FactoryBot.create(:campaign_template, franchise: current_user.franchise) }
  let!(:campaign_2) { FactoryBot.create(:campaign) }
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
        it 'returns all campaigns from given franchise' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :index, params: { franchise_id: campaign_2.franchise_id }
          expect(assigns(:campaigns)).to eq([campaign_2])
        end
      end
      it 'returns all templates' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:templates)).to eq(CampaignTemplate.all)
      end
      it 'returns all campaigns' do
        current_user.update superuser: true
        session[:user_id] = current_user.id
        get :index
        expect(assigns(:campaigns)).to eq(Campaign.all.order(created_at: :desc))
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
    it 'assigns @templates' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:templates)).to eq([campaign_template])
    end
    it 'returns all campaigns of current user franchise' do
      session[:user_id] = current_user.id
      get :index
      expect(assigns(:campaigns)).to eq(current_user.franchise.campaigns)
    end
  end

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
          post :create, params: { campaign: { name: 'Ma campagne', subject: 'Hello', body: 'Contenu de la campagne..', sms: false, recipients: ['sayid@gmail.com'] } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { campaign: { name: 'Ma campagne' } }
        }.not_to change(current_user.franchise.campaigns, :count)
      end
    end
    context 'when superuser' do
      it 'creates campaign for given franchise' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :create, params: { campaign: { franchise_id: franchise_2.id, name: 'Ma campagne', subject: 'Hello', body: 'Contenu de la campagne..', sms: false, recipients: ['sayid@gmail.com'] } }
        }.to change(franchise_2.campaigns, :count).by(1)
        expect(Campaign.last.name).to eq('Ma campagne')
        expect(Campaign.last.body).to eq('Contenu de la campagne..')
        expect(Campaign.last.sms).to eq(false)
        expect(Campaign.last.draft).to eq(true)
      end
    end
    it 'creates campaign' do
      expect {
        session[:user_id] = current_user.id
        post :create, params: { campaign: { name: 'Ma campagne', subject: 'Hello', body: 'Contenu de la campagne..', sms: false, recipients: ['sayid@gmail.com'] } }
      }.to change(current_user.franchise.campaigns, :count).by(1)
      expect(Campaign.last.name).to eq('Ma campagne')
      expect(Campaign.last.body).to eq('Contenu de la campagne..')
      expect(Campaign.last.sms).to eq(false)
      expect(Campaign.last.draft).to eq(true)
    end
  end

  describe 'PUT /:id' do
    let!(:campaign) { FactoryBot.create(:campaign, franchise: current_user.franchise) }
    context 'when not logged in' do
      it 'redirects to login form' do
        put :update, params: { id: campaign.id, campaign: { name: 'Titre2' } }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          put :update, params: { id: campaign.id, campaign: { name: '' } }
        }.not_to change(current_user.franchise.campaigns, :count)
      end
    end
    context 'when superuser' do
      it 'can update franchise_id' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          put :update, params: { id: campaign.id, campaign: { franchise_id: franchise_2.id, name: 'Titre2' } }
        }.to change(current_user.franchise.campaigns, :count).by(-1)
        expect(campaign.reload.franchise).to eq(franchise_2)
        expect(campaign.reload.name).to eq('Titre2')
      end
    end
    it 'updates campaign' do
      expect {
        session[:user_id] = current_user.id
        put :update, params: { id: campaign.id, campaign: { name: 'Titre2' } }
      }.not_to change(current_user.franchise.campaigns, :count)
      expect(campaign.reload.name).to eq('Titre2')
    end
  end

  describe 'GET :show' do
    let!(:campaign) { FactoryBot.create(:campaign, franchise: current_user.franchise) }
    let!(:campaign_2) { FactoryBot.create(:campaign) }
    context 'when not logged in' do
      it 'redirects to login form' do
        get :show, params: { id: campaign.id }
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
      context 'when campaign from another franchise' do
        it 'renders campaign page' do
          current_user.update superuser: true
          session[:user_id] = current_user.id
          get :show, params: { id: campaign_2.id }
          expect(assigns(:campaign)).to eq(campaign_2)
        end
      end
    end
    it 'renders campaign page' do
      session[:user_id] = current_user.id
      get :show, params: { id: campaign.id }
      expect(assigns(:campaign)).to eq(campaign)
    end
  end

  describe 'DELETE :destroy' do
    let!(:campaign) { FactoryBot.create(:campaign, franchise: current_user.franchise) }
    let!(:campaign_2) { FactoryBot.create(:campaign) }
    context 'when not logged in' do
      it 'redirects to login form' do
        delete :destroy, params: { id: campaign.id }
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
      context 'when campaign from another franchise' do
        it 'deletes campaign' do
          current_user.update superuser: true
          expect {
            session[:user_id] = current_user.id
            delete :destroy, params: { id: campaign_2.id }
          }.to change(campaign_2.franchise.campaigns, :count).by(-1)
        end
      end
    end
    it 'deletes campaign' do
      expect {
        session[:user_id] = current_user.id
        delete :destroy, params: { id: campaign.id }
      }.to change(current_user.franchise.campaigns, :count).by(-1)
    end
    it 'returns 204' do
      session[:user_id] = current_user.id
      delete :destroy, params: { id: campaign.id }
      expect(response.status).to eq(204)
    end
  end

  describe 'POST /:id/send_test' do
    let!(:campaign) { FactoryBot.create(:campaign, franchise: current_user.franchise) }
    context 'when not logged in' do
      xit 'redirects to login form' do
        post :send_test, params: { id: campaign.id, email: 'sayid.mimouni@gmail.com' }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      xit 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :send_test, params: { id: campaign.id, email: '' }
        }.to raise_error(ArgumentError)
      end
    end
    context 'when superuser' do
      xit 'sends test email' do
        expect {
          current_user.update superuser: true
          session[:user_id] = current_user.id
          post :send_test, params: { id: campaign.id, email: 'sayid.mimouni@gmail.com' }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
        expect(ActionMailer::Base.deliveries.first.to).to eq(['sayid.mimouni@gmail.com'])
        expect(ActionMailer::Base.deliveries.first.subject).to eq(campaign.subject)
        expect(ActionMailer::Base.deliveries.first.body.decoded).to eq(campaign.body)
      end
    end
    xit 'sends test email' do
      expect {
        session[:user_id] = current_user.id
        post :send_test, params: { id: campaign.id, email: 'sayid.mimouni@gmail.com' }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(ActionMailer::Base.deliveries.first.from).to eq(['contact@cryotera.fr'])
      expect(ActionMailer::Base.deliveries.first.to).to eq(['sayid.mimouni@gmail.com'])
      expect(ActionMailer::Base.deliveries.first.subject).to eq(campaign.subject)
      expect(ActionMailer::Base.deliveries.first.body.decoded).to eq(campaign.body)
    end
  end
end
