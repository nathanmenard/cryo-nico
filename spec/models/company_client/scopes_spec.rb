require 'rails_helper'

RSpec.describe CompanyClient, type: :model do
  describe '.find_by_private_key' do
    let(:company_client) { FactoryBot.create(:company_client) }
    context 'when does not exist' do
      it 'raises record not found' do
        expect {
          CompanyClient.find_by_private_key('invalid key')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    it 'returns company client' do
      expect(CompanyClient.find_by_private_key(company_client.private_key)).to eq(company_client)
    end
  end

  describe '.birthday_today' do
    it 'company_clients whose birthday is today' do
      company_client_a = FactoryBot.create(:company_client, birth_date: Date.today - 20.years)
      company_client_b = FactoryBot.create(:company_client, birth_date: Date.today - 30.years)
      company_client_c = FactoryBot.create(:company_client, birth_date: Date.today + 10.days - 30.years)
      expect(CompanyClient.birthday_today).to eq([company_client_a, company_client_b])
    end
  end
end
