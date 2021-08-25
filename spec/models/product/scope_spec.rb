require 'rails_helper'

RSpec.describe Product, type: :model do
  describe '.active' do
    it 'returns product with active = true' do
      product_a = FactoryBot.create(:product, active: true)
      FactoryBot.create(:product_price, product: product_a)
      product_b = FactoryBot.create(:product, active: false)
      FactoryBot.create(:product_price, product: product_b)
      expect(Product.active).to eq([product_a])
    end
    it 'excludes products with no product prices' do
      product_a = FactoryBot.create(:product)
      FactoryBot.create(:product_price, product: product_a)
      product_b = FactoryBot.create(:product)
      expect(Product.active).to eq([product_a])
    end
  end

  describe '.find_by_private_key' do
    let(:product) { FactoryBot.create(:product) }
    context 'when does not exist' do
      it 'raises record not found' do
        expect {
          Product.find_by_slug('invalid slug')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    it 'returns company client' do
      expect(Product.find_by_slug(product.slug)).to eq(product)
    end
  end

  describe 'scope .has_unit_price' do
    context 'when does not have product price for session_count = 1' do
      it 'does not include' do
        product_1 = FactoryBot.create(:product)
        product_2 = FactoryBot.create(:product)
        FactoryBot.create(:product_price, product: product_2, professionnal: false, session_count: 1)
        FactoryBot.create(:product_price, product: product_1, professionnal: true, session_count: 1)
        expect(Product.has_unit_price).to eq([product_2])
      end
    end
  end
end
