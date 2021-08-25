require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:product)).to be_valid
    expect(FactoryBot.create(:product)).to be_valid
  end

  it 'belongs to a room' do
    expect(FactoryBot.build(:product, room: nil)).not_to be_valid
  end

  it 'has a name' do
    expect(FactoryBot.build(:product, name: nil)).not_to be_valid
  end

  it 'has a description' do
    expect(FactoryBot.build(:product, description: nil)).not_to be_valid
  end

  it 'has a duration' do
    expect(FactoryBot.build(:product, duration: nil)).not_to be_valid
  end

  it 'has an active flag' do
    expect(FactoryBot.build(:product, active: nil)).not_to be_valid
    expect(FactoryBot.create(:product, active: true)).to be_valid
    expect(FactoryBot.create(:product, active: false)).to be_valid
  end

  describe '#payments' do
    xit 'returns payments'
  end

  describe '#unique_clients_count' do
    let(:product_1) { FactoryBot.create(:product) }
    let(:payment_1) { FactoryBot.create(:payment, bank_name: 'HSBC') }
    let(:payment_2) { FactoryBot.create(:payment, bank_name: 'HSBC') }
    let!(:product_price_1) { FactoryBot.create(:product_price, product: product_1) }
    let!(:reservation_1) { FactoryBot.create(:reservation, product_price: product_price_1, payment: payment_1) }
    let!(:reservation_2) { FactoryBot.create(:reservation, product_price: product_price_1, client: nil, company_client: FactoryBot.create(:company_client), payment: payment_2) }
    let!(:reservation_3) { FactoryBot.create(:reservation, product_price: product_price_1) }
    let!(:reservation_4) { FactoryBot.create(:reservation, product_price: product_price_1, client: reservation_1.client) }

    let(:product_2) { FactoryBot.create(:product) }
    let!(:product_price_2) { FactoryBot.create(:product_price, product: product_2) }
    let!(:reservation_5) { FactoryBot.create(:reservation, product_price: product_price_2) }

    it 'returns unique clients count with at least one payment' do
      expect(product_1.unique_clients_count).to eq(2)
      expect(product_2.unique_clients_count).to eq(0)
    end
  end

  describe '#average_payments_amount' do
    let(:product) { FactoryBot.create(:product) }
    let!(:product_price_1) { FactoryBot.create(:product_price, product: product, total: 50) }
    let!(:product_price_2) { FactoryBot.create(:product_price, product: product, total: 100) }
    let!(:payment_1) { FactoryBot.create(:payment, amount: 50*100, bank_name: 'Crédit Agricole') }
    let!(:payment_2) { FactoryBot.create(:payment, amount: 100*100, mode: 'cash', as_paid: true) }
    let!(:payment_3) { FactoryBot.create(:payment, amount: 200*100, as_paid: false) }
    let!(:reservation_1) { FactoryBot.create(:reservation, product_price: product_price_1, payment: payment_1) }
    let!(:reservation_2) { FactoryBot.create(:reservation, product_price: product_price_2, payment: payment_2) }
    it 'returns average amount of reservations' do
      expect(product.average_payments_amount).to eq(75)
    end
  end

  describe '#average_session_count_per_client' do
    let(:product) { FactoryBot.create(:product) }
    let(:client) { FactoryBot.create(:client, franchise: product.room.franchise) }
    let(:payment) { FactoryBot.create(:payment, :successful) }
    let!(:product_price_1) { FactoryBot.create(:product_price, product: product, session_count: 1) }
    let!(:product_price_2) { FactoryBot.create(:product_price, product: product, session_count: 10) }
    let!(:reservation_1) { FactoryBot.create(:reservation, client: client, product_price: product_price_1, payment: payment) }
    let!(:reservation_2) { FactoryBot.create(:reservation, client: client, product_price: product_price_1, payment: payment) }
    let!(:reservation_3) { FactoryBot.create(:reservation, client: client, product_price: product_price_1) }
    let!(:reservation_4) { FactoryBot.create(:reservation, product_price: product_price_2) }
    it 'returns average session count per client (paid & schedule reservations only)' do
      expect(product.average_session_count_per_client).to eq(2)
    end
  end

  describe '#opening_slots' do
    xit 'returns all slots given product duration' do
    end
  end

  describe '#ever_bought_by?' do
    let(:product) { FactoryBot.create(:product) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    context 'when client' do
      let(:client) { FactoryBot.create(:client) }
      context 'when any paid reservations' do
        let(:payment) { FactoryBot.create(:payment, :successful, client: client, product_name: product.name) }
        let!(:reservation) { FactoryBot.create(:reservation, client: client, product_price: product_price, payment: payment) }
        it 'returns true' do
          expect(product.ever_bought_by?(client)).to eq(true)
        end
      end
      context 'when no paid reservations' do
        let(:reservation) { FactoryBot.create(:reservation, client: client, product_price: product_price, product_name: product.name) }
        it 'returns false' do
          expect(product.ever_bought_by?(client)).to eq(false)
        end
      end
    end
    context 'when company client' do
      let(:company_client) { FactoryBot.create(:company_client) }
      context 'when any paid reservations' do
        let(:payment) { FactoryBot.create(:payment, :successful, company_client: company_client, product_name: product.name) }
        let!(:reservation) { FactoryBot.create(:reservation, company_client: company_client, product_price: product_price, payment: payment) }
        it 'returns true' do
          expect(product.ever_bought_by?(company_client)).to eq(true)
        end
      end
      context 'when no paid reservations' do
        let(:reservation) { FactoryBot.create(:reservation, company_client: company_client, product_price: product_price, product_name: product.name) }
        it 'returns false' do
          expect(product.ever_bought_by?(company_client)).to eq(false)
        end
      end
    end
  end
end
