require 'rails_helper'

RSpec.describe CompanyClient, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:company_client)).to be_valid
    expect(FactoryBot.create(:company_client)).to be_valid
  end

  it 'can belong to company client' do
    expect(FactoryBot.create(:company_client, company_client: FactoryBot.create(:company_client))).to be_valid
  end

  it 'has a first name' do
    expect(FactoryBot.build(:company_client, first_name: nil)).not_to be_valid
  end

  it 'has a last name' do
    expect(FactoryBot.build(:company_client, last_name: nil)).not_to be_valid
  end

  it 'has an email' do
    expect(FactoryBot.build(:company_client, email: nil)).not_to be_valid
  end

  it 'has a valid email' do
    expect(FactoryBot.create(:company_client, email: 'said@gmail.com')).to be_valid
    expect(FactoryBot.build(:company_client, email: 'said@gmail')).not_to be_valid
    expect(FactoryBot.build(:company_client, email: 'saidgmail')).not_to be_valid
  end

  it 'can have a password' do
    company_client = FactoryBot.create(:company_client, password: 'azerty')
    expect(company_client).to be_valid
    expect(company_client.authenticate('invalid password')).to eq(false)
    expect(company_client.authenticate('azerty')).to eq(company_client)
  end

  describe '#full_name' do
    let(:company_client) { FactoryBot.create(:company_client, last_name: 'Mimouni', first_name: 'Saïd') }
    it 'returns full name' do
      expect(company_client.full_name).to eq('MIMOUNI Saïd')
    end
  end

  describe '#can_make_reservations?' do
    let(:company_client) { FactoryBot.create(:company_client) }
    context 'when company client belongs to another one'do
      it 'returns true' do
        company_client.update!(company_client: FactoryBot.create(:company_client))
        expect(company_client.can_make_reservations?).to eq(true)
      end
    end
    context 'when company client does not belong to another one'do
      it 'returns true' do
        expect(company_client.can_make_reservations?).to eq(false)
      end
    end
  end
end
