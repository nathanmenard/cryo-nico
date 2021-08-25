require 'rails_helper'

RSpec.describe ProductPrice, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:product_price)).to be_valid
    expect(FactoryBot.create(:product_price)).to be_valid
  end

  it 'belongs to a product' do
    expect(FactoryBot.build(:product_price, product: nil)).not_to be_valid
  end

  it 'has a session count' do
    expect(FactoryBot.build(:product_price, session_count: nil)).not_to be_valid
  end

  it 'has a total' do
    expect(FactoryBot.build(:product_price, total: nil)).not_to be_valid
  end

  it 'has a professionnal flag' do
    expect(FactoryBot.build(:product_price, professionnal: true)).to be_valid
    expect(FactoryBot.build(:product_price, professionnal: false)).to be_valid
    expect(FactoryBot.build(:product_price, professionnal: nil)).not_to be_valid
  end

  describe '#unit_price' do
    it 'calculates the unit price' do
      product_price = FactoryBot.create(:product_price, session_count: 10, total: 30)
      expect(product_price.unit_price).to eq(3)

      product_price = FactoryBot.create(:product_price, session_count: 1, total: 30)
      expect(product_price.unit_price).to eq(30)

      product_price = FactoryBot.create(:product_price, session_count: 20, total: 499)
      expect(product_price.unit_price).to eq(24.95)
    end
  end
end
