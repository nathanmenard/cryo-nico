require 'rails_helper'

RSpec.describe CampaignTemplatesController, type: :controller do
  describe 'POST :upsert' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:current_user) { FactoryBot.create(:user, franchise: franchise) }
    before(:each) do
      body = {
        templates: [
          { id: 1, name: 'First template', subject: 'Hey!', htmlContent: 'Hello' },
          { id: 2, name: 'Second template', subject: 'Howdy!', htmlContent: 'Hello2' },
        ]
      }.to_json
      stub_request(:any, /api.sendinblue.com\/v3\/smtp\/templates/)
        .to_return(status: 200, body: body, headers: {})
    end

    context 'when not logged in' do
      it 'redirects to login form' do
        post :upsert
        expect(response).to redirect_to('/admin')
      end
    end
    it 'updates templates' do
      expect do
        session[:user_id] = current_user.id
        post :upsert
      end.to change(current_user.franchise.campaign_templates, :count).from(0).to(2)
      expect(CampaignTemplate.first.external_id).to eq(1)
      expect(CampaignTemplate.first.name).to eq('First template')
      expect(CampaignTemplate.first.subject).to eq('Hey!')
      expect(CampaignTemplate.first.html).to eq('Hello')
      expect(CampaignTemplate.last.external_id).to eq(2)
      expect(CampaignTemplate.last.name).to eq('Second template')
      expect(CampaignTemplate.last.subject).to eq('Howdy!')
      expect(CampaignTemplate.last.html).to eq('Hello2')
    end
    it 'redirects to campaigns' do
      session[:user_id] = current_user.id
      post :upsert
      expect(response).to redirect_to(campaigns_path)
    end
  end
end
