require 'rails_helper'

RSpec.describe Coupon, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:coupon)).to be_valid
    expect(FactoryBot.create(:coupon)).to be_valid
  end

  it 'belongs to franchise(s)' do
    expect(FactoryBot.build(:coupon, franchises: [])).not_to be_valid
    expect(FactoryBot.build(:coupon, franchises: [FactoryBot.create(:franchise)])).to be_valid
    expect(FactoryBot.build(:coupon, franchises: [FactoryBot.create(:franchise), FactoryBot.create(:franchise)])).to be_valid
  end

  it 'can belong to client' do
    expect(FactoryBot.build(:coupon, client: nil)).to be_valid
    expect(FactoryBot.build(:coupon, client: FactoryBot.create(:client))).to be_valid
  end

  it 'can belong to company_client' do
    expect(FactoryBot.build(:coupon, company_client: nil)).to be_valid
    expect(FactoryBot.build(:coupon, company_client: FactoryBot.create(:company_client))).to be_valid
  end

  it 'has a name' do
    expect(FactoryBot.build(:coupon, name: nil)).not_to be_valid
  end

  it 'has a value' do
    expect(FactoryBot.build(:coupon, value: nil)).not_to be_valid
  end

  it 'has a code' do
    expect(FactoryBot.build(:coupon, code: nil)).not_to be_valid
  end

  it 'has a type' do
    expect(FactoryBot.build(:coupon, percentage: nil)).not_to be_valid
  end

  it 'has a valid type' do
    expect(FactoryBot.build(:coupon, percentage: true)).to be_valid
    expect(FactoryBot.build(:coupon, percentage: false)).to be_valid
  end

it 'has a valid value' do
    expect(FactoryBot.build(:coupon, value: '10')).to be_valid
    expect(FactoryBot.build(:coupon, value: '20')).to be_valid
    expect(FactoryBot.build(:coupon, value: 'invalid')).not_to be_valid
  end

  it 'has a valid usage limit' do
    expect(FactoryBot.build(:coupon, usage_limit: '10')).to be_valid
    expect(FactoryBot.build(:coupon, usage_limit: '20')).to be_valid
    expect(FactoryBot.build(:coupon, usage_limit: 'invalid')).not_to be_valid
  end

  it 'has a valid usage limit per person' do
    expect(FactoryBot.build(:coupon, usage_limit_per_person: '10')).to be_valid
    expect(FactoryBot.build(:coupon, usage_limit_per_person: '20')).to be_valid
    expect(FactoryBot.build(:coupon, usage_limit_per_person: 'invalid')).not_to be_valid
  end


  context 'when not loyalty' do
    it 'has a unique code (scoped to franchise)' do
      franchise = FactoryBot.create(:franchise)
      franchise_b = FactoryBot.create(:franchise)
      expect(FactoryBot.create(:coupon, franchises: [franchise], code: 'abc')).to be_valid
      expect(FactoryBot.create(:coupon, franchises: [franchise], code: 'abc')).not_to be_valid
      expect(FactoryBot.build(:coupon, franchises: [franchise], code: 'Abc')).not_to be_valid
      expect(FactoryBot.build(:coupon, franchises: [franchise], code: 'ABC')).not_to be_valid
      expect(FactoryBot.create(:coupon, franchises: [franchise_b], code: 'Abc')).to be_valid
      expect(FactoryBot.create(:coupon, franchises: [franchise_b], code: 'ABC')).not_to be_valid
    end
  end

  context 'when loyalty' do
    it 'can have duplicate code' do
      franchise = FactoryBot.create(:franchise)
      expect(FactoryBot.create(:coupon, franchises: [franchise], loyalty: true, code: 'abc')).to be_valid
      expect(FactoryBot.create(:coupon, franchises: [franchise], loyalty: true, code: 'abc')).to be_valid
    end
  end

  it 'can be male/female' do
    expect(FactoryBot.build(:coupon, male: nil)).to be_valid
    expect(FactoryBot.build(:coupon, male: true)).to be_valid
    expect(FactoryBot.build(:coupon, male: false)).to be_valid
  end

  it 'can have objectives' do
    expect(FactoryBot.build(:coupon, objectives: nil)).to be_valid
    expect(FactoryBot.build(:coupon, objectives: ['health'])).to be_valid
    expect(FactoryBot.build(:coupon, objectives: ['health', 'sport'])).to be_valid
  end

  it 'can belong to products' do
    product = FactoryBot.create(:product)
    expect(FactoryBot.build(:coupon, product_ids: nil)).to be_valid
    expect(FactoryBot.build(:coupon, product_ids: [])).to be_valid
    expect(FactoryBot.build(:coupon, product_ids: [product.id])).to be_valid
    # expect { FactoryBot.build(:coupon, product_ids: [0]) }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it 'can be for new clients only' do
    expect(FactoryBot.build(:coupon, new_client: true)).to be_valid
    expect(FactoryBot.build(:coupon, new_client: false)).to be_valid
  end

  describe 'before_save #downcase_code' do
    it 'saves the code in lowercase' do
      coupon = FactoryBot.create(:coupon, code: 'BIENVENUE10')
      expect(coupon.code).to eq('bienvenue10')

      coupon_2 = FactoryBot.create(:coupon, code: 'Welcome20')
      expect(coupon_2.code).to eq('welcome20')

      coupon_3 = FactoryBot.create(:coupon, code: 'hello30')
      expect(coupon_3.code).to eq('hello30')
    end
  end

  describe 'before_save #format_objectives' do
    it 'gets rid of blank strings' do
      coupon = FactoryBot.create(:coupon, objectives: ['', 'sport'])
      expect(coupon.objectives).to eq(['sport'])
    end
  end

  describe 'before_save #format_product_ids' do
    it 'gets rid of blank strings' do
      coupon = FactoryBot.create(:coupon, product_ids: ['', '1'])
      expect(coupon.product_ids).to eq(['1'])
    end
  end

  describe 'scope #active' do
    it 'returns active coupons' do
      coupon = FactoryBot.create(:coupon, end_date: nil)
      coupon_b = FactoryBot.create(:coupon, end_date: Date.today)
      coupon_c = FactoryBot.create(:coupon, end_date: Date.today + 1.day)
      coupon_d = FactoryBot.create(:coupon, end_date: Date.today - 1.day)
      expect(Coupon.active).to eq([coupon, coupon_b, coupon_c])
    end
  end

  describe 'scope #expired' do
    it 'returns expired coupons' do
      coupon = FactoryBot.create(:coupon, end_date: nil)
      coupon_b = FactoryBot.create(:coupon, end_date: Date.today)
      coupon_c = FactoryBot.create(:coupon, end_date: Date.today + 1.day)
      coupon_d = FactoryBot.create(:coupon, end_date: Date.today - 1.day)
      expect(Coupon.expired).to eq([coupon_d])
    end
  end

  describe '#active?' do
    context 'when coupon is expired' do
      it 'returns false' do
        coupon = FactoryBot.create(:coupon, end_date: Date.today - 1.day)
        expect(coupon.active?).to eq(false)
      end
    end
    context 'when coupon is active' do
      it 'returns true' do
        coupon = FactoryBot.create(:coupon, end_date: nil)
        expect(coupon.active?).to eq(true)

        coupon_b = FactoryBot.create(:coupon, end_date: Date.today)
        expect(coupon_b.active?).to eq(true)

        coupon_c = FactoryBot.create(:coupon, end_date: Date.today + 1.day)
        expect(coupon_c.active?).to eq(true)
      end
    end
  end

  describe '#applicable?' do
    let(:client) { FactoryBot.create(:client) }
    let(:coupon) { FactoryBot.create(:coupon) }
    let(:reservation) { FactoryBot.create(:reservation, client: client) }
    context 'when start_date in the future' do
      it 'returns false' do
        coupon.update start_date: (Date.today + 1.day)
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when end_date in the past' do
      it 'returns false' do
        coupon.update end_date: (Date.today - 1.day)
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when usage limit reached' do
      it 'returns false' do
        FactoryBot.create(:payment, coupon: coupon)
        coupon.update(usage_limit: 1)
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when usage limit per person reached' do
      it 'returns false' do
        FactoryBot.create(:payment, client: client, coupon: coupon)
        coupon.update(usage_limit_per_person: 1)
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when client does not have the wanted gender' do
      it 'returns false' do
        client.update(male: true)
        coupon.update(male: false)
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when client does not have the wanted objective' do
      it 'returns false' do
        client.update(objectives: ['health'])
        coupon.update(objectives: ['sport'])
        expect(coupon.applicable?(reservation)).to eq(false)

        client.update objectives: ['health', 'sport']
        coupon.update objectives: ['well-being', 'look']
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when coupon is not linked to current product' do
      it 'returns false' do
        product = FactoryBot.create(:product)
        coupon.update product_ids: [product.id]
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when coupon is for new client only && current client is not new' do
      it 'returns false' do
        FactoryBot.create(:reservation, client: client)
        coupon.update new_client: true
        expect(coupon.applicable?(reservation)).to eq(false)
      end
    end
    context 'when start_date is before today' do
      it 'returns true' do
        coupon.update(start_date: (Date.today - 1.day))
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when end_date is after today' do
      it 'returns true' do
        coupon.update(end_date: (Date.today + 1.day))
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when usage limit not reached' do
      it 'returns true' do
        FactoryBot.create(:payment, coupon: coupon)
        coupon.update(usage_limit: 2)
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when usage limit per person not reached' do
      it 'returns false' do
        FactoryBot.create(:payment, client: client, coupon: coupon)
        coupon.update(usage_limit_per_person: 2)
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when client has the wanted gender' do
      it 'returns true' do
        client.update(male: true)
        coupon.update(male: true)
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when client has the wanted objective' do
      it 'returns true' do
        client.update objectives: ['health']
        coupon.update objectives: ['sport', 'health']
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when coupon is linked to current product' do
      it 'returns true' do
        coupon.update product_ids: [reservation.product_price.product.id]
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
    context 'when coupon is for new client only && current client is new' do
      it 'returns true' do
        coupon.update new_client: true
        expect(coupon.applicable?(reservation)).to eq(true)
      end
    end
  end

  describe '#discount_amount' do
    it 'returns the total amount of discount' do
      franchise = FactoryBot.create(:franchise)
      room = FactoryBot.create(:room, franchise: franchise)
      product = FactoryBot.create(:product, room: room)
      product_price = FactoryBot.create(:product_price, product: product, total: 100)
      coupon = FactoryBot.create(:coupon, franchises: [franchise], percentage: true, value: 25)
      payment = FactoryBot.create(:payment, amount: 100*100)
      reservation = FactoryBot.create(:reservation, payment: payment, product_price: product_price)
      expect(coupon.applicable?(reservation)).to eq(true)
      expect(coupon.discount_amount(payment)).to eq(25)

      coupon.update(percentage: false, value: 30)
      expect(coupon.applicable?(reservation)).to eq(true)
      expect(coupon.discount_amount(payment)).to eq(30)
    end
  end
end
