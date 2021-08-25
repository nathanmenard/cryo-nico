require 'rails_helper'

RSpec.describe ExternalProduct, type: :model do
  it 'has valid factory' do
    expect(FactoryBot.build(:external_product)).to be_valid
    expect(FactoryBot.create(:external_product)).to be_valid
  end

  describe '#payments' do
    let(:external_product) { FactoryBot.create(:external_product) }
    let!(:payment) { FactoryBot.create(:payment, product_name: external_product.name) }
    it 'returns payments for given external product' do
      expect(external_product.payments).to eq([payment])
    end
  end

  describe '#unique_clients_count' do
    let(:external_product_1) { FactoryBot.create(:external_product, name: 'abc') }
    let!(:payment_1) { FactoryBot.create(:payment, :successful, product_name: external_product_1.name) }
    let!(:payment_2) { FactoryBot.create(:payment, :successful, product_name: external_product_1.name) }

    let(:external_product_2) { FactoryBot.create(:external_product, name: 'def') }
    let!(:payment_3) { FactoryBot.create(:payment, product_name: external_product_2.name) }

    it 'returns unique clients count with at least one successful payment' do
      expect(external_product_1.unique_clients_count).to eq(2)
      expect(external_product_2.unique_clients_count).to eq(0)
    end
  end

  describe '#revenue_without_tax' do
    let(:external_product_1) { FactoryBot.create(:external_product, name: 'abc', amount: 10, tax_rate: 20) }
    let(:external_product_2) { FactoryBot.create(:external_product, name: 'def', amount: 10, tax_rate: 5.5) }
    let!(:payment_1) { FactoryBot.create(:payment, :successful, amount: 10*100, product_name: external_product_1.name, tax_rate: external_product_1.tax_rate) }
    let!(:payment_2) { FactoryBot.create(:payment, :successful, amount: 10*100, product_name: external_product_1.name, tax_rate: external_product_1.tax_rate) }
    let!(:payment_3) { FactoryBot.create(:payment, :successful, amount: 10*100, product_name: external_product_1.name, tax_rate: external_product_1.tax_rate) }
    let!(:payment_4) { FactoryBot.create(:payment, :successful, amount: 10*100, product_name: external_product_2.name, tax_rate: external_product_2.tax_rate) }
    let!(:payment_5) { FactoryBot.create(:payment, product_name: external_product_2.name, tax_rate: external_product_2.tax_rate) }

    it 'returns total revenue for external product without tax' do
      expect(external_product_1.revenue_without_tax).to eq(24)
      expect(external_product_2.revenue_without_tax).to eq(9.45)
    end
  end
end
