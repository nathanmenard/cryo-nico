require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product)       { FactoryBot.create(:product) }
  let(:product_price) { FactoryBot.create(:product_price, product: product) }

  describe '#male_vs_female' do
    let(:client_male)   { FactoryBot.create(:client, male: true) }
    let(:client_female) {  FactoryBot.create(:client, male: false) }

    it' returns % of male/female clients' do
      3.times do
        FactoryBot.create(:reservation, product_price: product_price, client: client_male)
      end
      FactoryBot.create(:reservation, product_price: product_price, client: client_female)

      expect(product.male_vs_female).to eq({
        male: 75,
        female: 25
      })
    end
  end

  describe '#client_vs_company_client' do
    let(:client)          { FactoryBot.create(:client) }
    let(:company_client)  {  FactoryBot.create(:company_client) }

    it'returns % of client/company client' do
      3.times do
        FactoryBot.create(:reservation, product_price: product_price, company_client: nil, client: client)
      end
      FactoryBot.create(:reservation, product_price: product_price, client: nil, company_client: company_client)

      expect(product.client_vs_company_client).to eq({
        client: 75,
        company_client: 25
      })
    end
  end

  describe '#subscriber_vs_non_subscriber' do
    let(:subscriber)      { FactoryBot.create(:client, franchise: product.room.franchise) }
    let!(:subscription)   { FactoryBot.create(:subscription, client: subscriber) }
    let(:non_subscriber)  { FactoryBot.create(:client) }

    it'returns % of subscriber/non-subscriber' do
      3.times do
        FactoryBot.create(:reservation, product_price: product_price, company_client: nil, client: subscriber)
      end
      FactoryBot.create(:reservation, product_price: product_price, client: non_subscriber)

      expect(product.subscriber_vs_non_subscriber).to eq({
        subscriber: 75,
        non_subscriber: 25
      })
    end
  end

  describe '#group_by_hour' do
    it'returns % of subscriber/non-subscriber' do
      3.times do
        FactoryBot.create(:reservation, product_price: product_price, start_time: '2021-01-01T09:00')
      end
      2.times do
        FactoryBot.create(:reservation, product_price: product_price, start_time: '2021-01-01T09:30')
      end
      FactoryBot.create(:reservation, product_price: product_price, start_time: '2021-01-01T10:00')

      expect(product.group_by_hour['09:00']).to eq(50)
      expect(product.group_by_hour['09:30']).to eq(34)
      expect(product.group_by_hour['10:00']).to eq(17)
      expect(product.group_by_hour['10:30']).to eq(0)
    end
  end
end
