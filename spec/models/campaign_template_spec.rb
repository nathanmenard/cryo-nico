require 'rails_helper'

RSpec.describe CampaignTemplate, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:campaign_template)).to be_valid
    expect(FactoryBot.create(:campaign_template)).to be_valid
  end

  it 'belongs to franchise' do
    expect(FactoryBot.build(:campaign_template, franchise: nil)).not_to be_valid
  end

  it 'has external id' do
    expect(FactoryBot.build(:campaign_template, external_id: nil)).not_to be_valid
  end

  it 'has name' do
    expect(FactoryBot.build(:campaign_template, name: nil)).not_to be_valid
  end

  it 'has subject' do
    expect(FactoryBot.build(:campaign_template, subject: nil)).not_to be_valid
  end

  it 'has unique external id' do
    expect(FactoryBot.create(:campaign_template, external_id: 1)).to be_valid
    expect(FactoryBot.build(:campaign_template, external_id: 1)).not_to be_valid
  end

  describe '#refresh_templates_list' do
    let(:franchise) { FactoryBot.create(:franchise) }
    context 'when templates' do
      it 'creates templates in database' do
        body = {
          templates: [
            { id: 1, name: 'First template', subject: 'Hey!', htmlContent: '<b>Hello</b>' },
            { id: 2, name: 'Second template', subject: 'Howdy!', htmlContent: '<b>Hello2</b>' },
          ]
        }.to_json
        stub_request(:any, /api.sendinblue.com\/v3\/smtp\/templates/)
          .to_return(status: 200, body: body, headers: {})
        expect do
          CampaignTemplate.fetch(franchise)
        end.to change(CampaignTemplate, :count).by(2)
        expect(CampaignTemplate.first.external_id).to eq(1)
        expect(CampaignTemplate.first.name).to eq('First template')
        expect(CampaignTemplate.first.subject).to eq('Hey!')
        expect(CampaignTemplate.first.html).to eq('<b>Hello</b>')
        expect(CampaignTemplate.last.external_id).to eq(2)
        expect(CampaignTemplate.last.name).to eq('Second template')
        expect(CampaignTemplate.last.subject).to eq('Howdy!')
        expect(CampaignTemplate.last.html).to eq('<b>Hello2</b>')
      end
    end
    context 'when existing templates' do
      it 'updates templates in database' do
        FactoryBot.create(:campaign_template, franchise: franchise, external_id: 1, name: 'First', subject: 'Hey!')
        FactoryBot.create(:campaign_template, franchise: franchise, external_id: 2, name: 'Second template', subject: 'Hello!')
        body = {
          templates: [
            { id: 1, name: 'First template', subject: 'Hey!', htmlContent: '<u>Hey</u>' },
            { id: 2, name: 'Second template', subject: 'Howdy!', htmlContent: '<u>Hey2</u>' },
          ]
        }.to_json
        stub_request(:any, /api.sendinblue.com\/v3\/smtp\/templates/)
          .to_return(status: 200, body: body, headers: {})
        expect do
          CampaignTemplate.fetch(franchise)
        end.not_to change(CampaignTemplate, :count)
        expect(CampaignTemplate.first.external_id).to eq(1)
        expect(CampaignTemplate.first.name).to eq('First template')
        expect(CampaignTemplate.first.subject).to eq('Hey!')
        expect(CampaignTemplate.first.html).to eq('<u>Hey</u>')
        expect(CampaignTemplate.last.external_id).to eq(2)
        expect(CampaignTemplate.last.name).to eq('Second template')
        expect(CampaignTemplate.last.subject).to eq('Howdy!')
        expect(CampaignTemplate.last.html).to eq('<u>Hey2</u>')
      end
    end
  end
end
