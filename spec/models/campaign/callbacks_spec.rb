require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'after_create #create_in_sendinblue' do
    it 'creates sendinblue list' do
      campaign_template = FactoryBot.create(:campaign_template)
      campaign = FactoryBot.create(:campaign, campaign_template: campaign_template)
      expect(campaign.sendinblue_list_id).not_to eq(nil)
      expect(campaign.sendinblue_campaign_id).not_to eq(nil)
    end
  end

  describe 'after_update #fetch_recipients' do
    let(:campaign) { FactoryBot.create(:campaign) }
    context 'when already sent' do
      it 'does not update recipients' do
        campaign = FactoryBot.create(:campaign, draft: false)
        expect {
          campaign.update(name: 'Hello')
        }.not_to change(campaign.reload, :recipients)
      end
    end
    context 'when filters has not been changed' do
      it 'does not update recipients' do
        expect {
          campaign.update(name: 'Hello')
        }.not_to change(campaign.reload, :recipients)
      end
    end
    it 'calls #empty_sendinblue_list' do
      expect(campaign).to receive(:empty_sendinblue_list)
      campaign.update(filters: { male: 'true' })
    end
    it 'calls #save_contacts_in_sendinblue' do
      expect(campaign).to receive(:save_contacts_in_sendinblue)
      campaign.update(filters: { male: 'true' })
    end
    context 'when filters.male changed' do
      context 'when campaign.sms?' do
        it 'updates recipients (phone)' do
          client = FactoryBot.create(:client, franchise: campaign.franchise, male: true, phone: '0620853909')
          FactoryBot.create(:client, franchise: campaign.franchise, male: false)
          expect {
            campaign.update(sms: true, filters: { male: 'true' })
          }.to change(campaign.reload, :recipients)
          expect(campaign.reload.recipients).to eq([client.phone])
        end
      end
      context 'when campaign not sms' do
        it 'updates recipients (email)' do
          client = FactoryBot.create(:client, franchise: campaign.franchise, male: true)
          FactoryBot.create(:client, franchise: campaign.franchise, male: false)
          expect {
            campaign.update(filters: { male: 'true' })
          }.to change(campaign.reload, :recipients)
          expect(campaign.reload.recipients).to eq([client.email])
        end
      end
      context 'when filters.objectives changed' do
        it 'updates recipients' do
          client = FactoryBot.create(:client, franchise: campaign.franchise, objectives: ['health', 'sport'])
          FactoryBot.create(:client, franchise: campaign.franchise, objectives: ['sport'])
          expect {
            campaign.update(filters: { objectives: ['health'] })
          }.to change(campaign.reload, :recipients)
          expect(campaign.reload.recipients).to eq([client.email])
        end
      end
      context 'when filters.product changed' do
        it 'updates recipients' do
          room = FactoryBot.create(:room, franchise: campaign.franchise)
          client = FactoryBot.create(:client, franchise: campaign.franchise)
          room = FactoryBot.create(:room, franchise: campaign.franchise)
          product = FactoryBot.create(:product, room: room)
          product_price = FactoryBot.create(:product_price, product: product)
          reservation = FactoryBot.create(:reservation, product_price: product_price, client: client)
          FactoryBot.create(:client, franchise: campaign.franchise)
          expect {
            campaign.update(filters: { product_id: product.id })
          }.to change(campaign.reload, :recipients)
          expect(campaign.reload.recipients).to eq([client.email])
        end
      end
      context 'when filters.last_reservation_date changed' do
        it 'updates recipients' do
          room = FactoryBot.create(:room, franchise: campaign.franchise)
          client = FactoryBot.create(:client, franchise: campaign.franchise)
          client_2 = FactoryBot.create(:client, franchise: campaign.franchise)
          room = FactoryBot.create(:room, franchise: campaign.franchise)
          product = FactoryBot.create(:product, room: room)
          product_price = FactoryBot.create(:product_price, product: product)
          FactoryBot.create(:reservation, product_price: product_price, start_time: Date.yesterday, client: client)
          FactoryBot.create(:reservation, product_price: product_price, start_time: Date.today, client: client)
          reservation = FactoryBot.create(:reservation, product_price: product_price, start_time: Date.yesterday, client: client_2)
          expect {
            campaign.update(filters: { last_reservation_date: Date.yesterday.to_s })
          }.to change(campaign.reload, :recipients)
          expect(campaign.reload.recipients).to eq([client_2.email])
        end
      end
      context 'when mutiple filters changed' do
        it 'updates recipients' do
          room = FactoryBot.create(:room, franchise: campaign.franchise)
          client_a = FactoryBot.create(:client, franchise: campaign.franchise, male: true)
          client_b = FactoryBot.create(:client, franchise: campaign.franchise, male: false)
          room = FactoryBot.create(:room, franchise: campaign.franchise)
          product = FactoryBot.create(:product, room: room)
          product_price = FactoryBot.create(:product_price, product: product)
          reservation = FactoryBot.create(:reservation, product_price: product_price, client: client_a)
          reservation = FactoryBot.create(:reservation, product_price: product_price, client: client_b)
          FactoryBot.create(:client, franchise: campaign.franchise)
          expect {
            campaign.update(filters: { product_id: product.id, male: 'false' })
          }.to change(campaign.reload, :recipients)
          expect(campaign.reload.recipients).to eq([client_b.email])
        end
      end
    end
  end
end
