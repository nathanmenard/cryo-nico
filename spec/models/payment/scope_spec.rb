require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe '.today' do
    it 'returns payments of current date' do
      payment_a = FactoryBot.create(:payment, created_at: Date.today)
      payment_b = FactoryBot.create(:payment, created_at: Date.today - 1.day)
      payment_c = FactoryBot.create(:payment, created_at: Date.today + 1.day)
      expect(Payment.today).to eq([payment_a])
    end
  end

  describe '.successful' do
    it 'returns payments with successful?=true' do
      payment_a = FactoryBot.create(:payment, mode: 'online', bank_name: 'Crédit Agricole')
      payment_b = FactoryBot.create(:payment, mode: 'cash', as_paid: true)
      payment_c = FactoryBot.create(:payment, mode: 'online')
      expect(Payment.successful).to eq([payment_a, payment_b])
    end
  end

  describe '.find_by_date_id' do
    context 'when payment not found' do
      it 'returns nil' do
        expect(Payment.find_by_date_id('hello')).to eq(nil)
      end
    end
    it 'returns payment' do
      payment = FactoryBot.create(:payment)
      expect(Payment.find_by_date_id(payment.date_id)).to eq(payment)
    end
  end

  describe '.by_product' do
    it 'returns all payments for given product name' do
      product = FactoryBot.create(:product)
      payment_a = FactoryBot.create(:payment, product_name: product.name)
      payment_b = FactoryBot.create(:payment, product_name: product.name)
      payment_c = FactoryBot.create(:payment)
      expect(Payment.by_product(product.name)).to eq([payment_a, payment_b])
    end
  end
end
