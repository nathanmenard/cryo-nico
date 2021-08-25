require 'rails_helper'

RSpec.describe Franchise, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:franchise)).to be_valid
    expect(FactoryBot.create(:franchise)).to be_valid
  end

  it 'has a unique name' do
    expect(FactoryBot.create(:franchise, name: 'Reims')).to be_valid
    expect(FactoryBot.build(:franchise, name: 'Reims')).not_to be_valid
  end

  it 'can have banking details' do
    expect(FactoryBot.create(:franchise, banking_provider: 'Banque Populaire')).to be_valid
    expect(FactoryBot.create(:franchise, banking_secret_key: 'foobar')).to be_valid
    expect(FactoryBot.create(:franchise, banking_secret_id: 'foo')).to be_valid
  end

  it 'can have a valid email' do
    expect(FactoryBot.build(:franchise, email: nil)).to be_valid
    expect(FactoryBot.build(:franchise, email: 'contact')).not_to be_valid
    expect(FactoryBot.build(:franchise, email: 'contact@a')).not_to be_valid
    expect(FactoryBot.create(:franchise, email: 'contact@gmail.com')).to be_valid
  end

  it 'can have a tax id' do
    expect(FactoryBot.create(:franchise, tax_id: nil)).to be_valid
    expect(FactoryBot.create(:franchise, tax_id: '123')).to be_valid
  end

  it 'can have a valid siret' do
    expect(FactoryBot.create(:franchise, siret: nil)).to be_valid
    expect(FactoryBot.create(:franchise, siret: '81214811200012')).to be_valid
    expect(FactoryBot.build(:franchise, siret: '5110')).not_to be_valid
    expect(FactoryBot.build(:franchise, siret: 'invalid siret_number')).not_to be_valid
  end

  it 'can have an address' do
    expect(FactoryBot.create(:franchise, address: nil)).to be_valid
    expect(FactoryBot.create(:franchise, address: '60 rue des Gobelins')).to be_valid
  end

  it 'can have a valid zip code' do
    expect(FactoryBot.create(:franchise, zip_code: nil)).to be_valid
    expect(FactoryBot.create(:franchise, zip_code: '51100')).to be_valid
    expect(FactoryBot.build(:franchise, zip_code: 'invalid zip code')).not_to be_valid
  end

  it 'can have a city' do
    expect(FactoryBot.create(:franchise, city: nil)).to be_valid
    expect(FactoryBot.create(:franchise, city: 'Reims')).to be_valid
  end

  it 'can have an iban' do
    expect(FactoryBot.create(:franchise, iban: nil)).to be_valid
    expect(FactoryBot.create(:franchise, iban: '12')).to be_valid
  end

  it 'can have a valid zip code' do
    expect(FactoryBot.create(:franchise, phone: nil)).to be_valid
    expect(FactoryBot.create(:franchise, phone: '0620853909')).to be_valid
    expect(FactoryBot.build(:franchise, phone: 'invalid phone')).not_to be_valid
  end

  it 'can have instagram username' do
    expect(FactoryBot.create(:franchise, instagram_username: nil)).to be_valid
    expect(FactoryBot.create(:franchise, instagram_username: '12')).to be_valid
  end

  describe '#slug' do
    it 'returns slug based on name' do
      franchise = FactoryBot.create(:franchise, name: 'Reims')
      expect(franchise.slug).to eq('reims')

      franchise_2 = FactoryBot.create(:franchise, name: 'Los Angeles')
      expect(franchise_2.slug).to eq('los-angeles')

      franchise_3 = FactoryBot.create(:franchise, name: 'Nîmes')
      expect(franchise_3.slug).to eq('nimes')
    end
  end

  describe '#reservations' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let(:room) { FactoryBot.create(:room, franchise: franchise) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let!(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    let!(:reservation_2) { FactoryBot.create(:reservation) }
    it 'returns reservations' do
      expect(franchise.reservations).to eq([reservation])
    end
  end

  describe '#coupons' do
    let(:franchise) { FactoryBot.create(:franchise) }
    it 'returns coupons attached to franchise' do
      coupon = FactoryBot.create(:coupon, franchises: [franchise])
      expect(franchise.coupons).to eq([coupon])
    end
  end
end
