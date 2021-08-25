require 'rails_helper'

RSpec.describe Client, type: :model do
  it 'has valid factory' do
    expect(FactoryBot.build(:client)).to be_valid
    expect(FactoryBot.create(:client)).to be_valid
  end

  it 'can belong to client' do
    expect(FactoryBot.build(:client, client: nil)).to be_valid
    expect(FactoryBot.build(:client, client: FactoryBot.create(:client))).to be_valid
  end

  it 'can belong to user' do
    expect(FactoryBot.build(:client, user: nil)).to be_valid
    expect(FactoryBot.build(:client, user: FactoryBot.create(:user))).to be_valid
  end

  it 'has first_name' do
    expect(FactoryBot.build(:client, first_name: nil)).not_to be_valid
  end

  it 'has last_name' do
    expect(FactoryBot.build(:client, last_name: nil)).not_to be_valid
  end

  it 'has gender' do
    expect(FactoryBot.build(:client, male: nil)).not_to be_valid
  end

  it 'can have password' do
    client = FactoryBot.create(:client, password: 'azerty')
    expect(client).to be_valid
    expect(client.authenticate('invalid password')).to eq(false)
    expect(client.authenticate('azerty')).to eq(client)
  end

  xit 'has valid birth date' do
    expect(FactoryBot.build(:client, birth_date: '03/08/1993')).to be_valid
    expect(FactoryBot.build(:client, birth_date: '03.08.1993')).not_to be_valid
    expect(FactoryBot.build(:client, birth_date: 'invalid birth date')).not_to be_valid
  end

  it 'has valid email' do
    expect(FactoryBot.create(:client, email: 'said@gmail.com')).to be_valid
    expect(FactoryBot.build(:client, email: nil)).not_to be_valid
    expect(FactoryBot.build(:client, email: 'said@gmail')).not_to be_valid
    expect(FactoryBot.build(:client, email: 'saidgmail')).not_to be_valid
  end

  it 'has valid phone' do
    expect(FactoryBot.create(:client, phone: '0620853909')).to be_valid
    expect(FactoryBot.build(:client, phone: '06.20.85.39.09')).not_to be_valid
    expect(FactoryBot.build(:client, phone: '062085390')).not_to be_valid
    expect(FactoryBot.build(:client, phone: 'invalid phone_number')).not_to be_valid
  end

  it 'has valid zip_code' do
    expect(FactoryBot.create(:client, zip_code: '51100')).to be_valid
    expect(FactoryBot.build(:client, zip_code: '5110')).not_to be_valid
    expect(FactoryBot.build(:client, zip_code: 'invalid zip_code_number')).not_to be_valid
  end

  describe '#credits_for(:product)' do
    let(:product) { FactoryBot.create(:product) }
    let(:client) { FactoryBot.create(:client) }
    context 'when has no credits' do
      it 'returns zero' do
        expect(client.credits_for(:product)).to eq(0)
      end
    end
    it 'returns sum of credits for couple user/product' do
      FactoryBot.create(:credit, product: product, client: client)
      expect(client.credits_for(product)).to eq(1)
      FactoryBot.create(:credit, product: product, client: client)
      expect(client.credits_for(product)).to eq(2)
    end
  end

  describe '#subscriber?' do
    let(:client) { FactoryBot.create(:client) }
    context 'when client does not have subscription' do
      it 'returns false' do
        expect(client.subscriber?).to eq(false)
      end
    end
    context 'when client has subscription' do
      it 'returns true' do
        FactoryBot.create(:subscription, client: client)
        expect(client.subscriber?).to eq(true)
      end
    end
  end
end
