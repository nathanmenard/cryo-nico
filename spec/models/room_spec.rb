require 'rails_helper'

RSpec.describe Room, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:room)).to be_valid
    expect(FactoryBot.create(:room)).to be_valid
  end

  it 'has a name' do
    expect(FactoryBot.build(:room, name: nil)).not_to be_valid
  end

  it 'has a capacity' do
    expect(FactoryBot.build(:room, capacity: nil)).not_to be_valid
  end

  describe '.has_active_products' do
    let(:room) { FactoryBot.create(:room) }
    context 'when room has active product with unit pricing' do
      it 'returns room' do
        product = FactoryBot.create(:product, room: room, active: true)
        FactoryBot.create(:product_price, product: product, professionnal: false, session_count: 1)
        expect(Room.has_active_products).to eq([room])
      end
    end
    context 'when room has active product but no pricing' do
      it 'returns room' do
        FactoryBot.create(:product, room: room, active: true)
        expect(Room.has_active_products).to eq([])
      end
    end
    context 'when room has product but not active' do
      it 'does not return room' do
        FactoryBot.create(:product, room: room, active: false)
        expect(Room.has_active_products).to eq([])
      end
    end
    context 'when room has no products' do
      it 'does not return room' do
        expect(Room.has_active_products).to eq([])
      end
    end
  end
end
