require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:campaign)).to be_valid
    expect(FactoryBot.create(:campaign)).to be_valid
  end

  it 'belongs to franchise' do
    expect(FactoryBot.build(:campaign, franchise: nil)).not_to be_valid
  end

  it 'has name' do
    expect(FactoryBot.build(:campaign, name: nil)).not_to be_valid
  end

  it 'has body' do
    expect(FactoryBot.build(:campaign, body: nil)).not_to be_valid
  end

  it 'can have recipients' do
    expect(FactoryBot.build(:campaign, recipients: nil)).to be_valid
    expect(FactoryBot.build(:campaign, recipients: [])).to be_valid
    expect(FactoryBot.build(:campaign, recipients: ['sayid@gmail.com'])).to be_valid
    expect(FactoryBot.build(:campaign, recipients: ['0620853909'])).to be_valid
  end

  it 'has sms flag' do
    expect(FactoryBot.build(:campaign, sms: nil)).not_to be_valid
    expect(FactoryBot.create(:campaign, sms: true)).to be_valid
    expect(FactoryBot.create(:campaign, sms: false)).to be_valid
  end

  it 'has draft flag' do
    expect(FactoryBot.build(:campaign, draft: nil)).not_to be_valid
    expect(FactoryBot.create(:campaign, draft: true)).to be_valid
    expect(FactoryBot.create(:campaign, draft: false)).to be_valid
  end

  it 'can have filters hash' do
    expect(FactoryBot.create(:campaign, filters: nil)).to be_valid
    expect(FactoryBot.create(:campaign, filters: { male: true })).to be_valid
  end

  describe '#send_now' do
    let(:campaign) { FactoryBot.create(:campaign) }
    context 'when already sent' do
      it 'returns false' do
        campaign.update(draft: false)
        expect(campaign.send_now).to eq(false)
      end
    end
    it 'updates draft to false' do
      expect {
        campaign.send_now
      }.to change(campaign.reload, :draft).from(true).to(false)
    end
    it 'returns true' do
      expect(campaign.send_now).to eq(true)
    end
  end
end
