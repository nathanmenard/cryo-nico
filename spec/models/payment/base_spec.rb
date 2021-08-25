require 'rails_helper'

RSpec.describe Payment, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:payment)).to be_valid
    expect(FactoryBot.create(:payment)).to be_valid
  end

  it 'can belong to client' do
    expect(FactoryBot.create(:payment, company_client: FactoryBot.create(:company_client), client: nil)).to be_valid
    expect(FactoryBot.create(:payment, client: FactoryBot.create(:client))).to be_valid
  end

  it 'can belong to company client' do
    expect(FactoryBot.create(:payment, client: FactoryBot.create(:client), company_client: nil)).to be_valid
    expect(FactoryBot.create(:payment, company_client: FactoryBot.create(:company_client))).to be_valid
  end

  it 'belongs to either client or company client' do
    expect(FactoryBot.build(:payment, client: nil, company_client: nil)).not_to be_valid
  end

  it 'can belong to coupon' do
    expect(FactoryBot.create(:payment, coupon: nil)).to be_valid
    expect(FactoryBot.create(:payment, coupon: FactoryBot.create(:coupon))).to be_valid
  end

  it 'has valid mode' do
    expect(FactoryBot.build(:payment, mode: 'online')).to be_valid
    expect(FactoryBot.build(:payment, mode: 'pos')).to be_valid
    expect(FactoryBot.build(:payment, mode: 'check')).to be_valid
    expect(FactoryBot.build(:payment, mode: 'cash')).to be_valid
    expect(FactoryBot.build(:payment, mode: nil)).to be_valid
    expect(FactoryBot.build(:payment, mode: 'azerty')).not_to be_valid
  end

  context 'when mode == online' do
    it 'has transaction_id' do
      payment = FactoryBot.create(:payment, mode: 'online')
      expect(payment.transaction_id).not_to eq(nil)
    end
  end

  context 'when mode != online' do
    it 'does not have transaction_id' do
      payment = FactoryBot.create(:payment, mode: 'cash')
      expect(payment.transaction_id).to eq(nil)

      payment_2 = FactoryBot.create(:payment, mode: 'pos')
      expect(payment_2.transaction_id).to eq(nil)

      payment_3 = FactoryBot.create(:payment, mode: 'check')
      expect(payment_3.transaction_id).to eq(nil)
    end
  end

  describe '#succesful?' do
    let(:payment) { FactoryBot.create(:payment) }
    context 'when has bank name' do
      it 'returns true' do
        payment.update!(bank_name: 'Crédit Agricole')
        expect(payment.successful?).to eq(true)
      end
    end
    context 'when as_paid flag set to true' do
      it 'returns true' do
        payment.update!(mode: 'online', as_paid: true)
        expect(payment.successful?).to eq(false)

        payment.update!(mode: 'cash', as_paid: true)
        expect(payment.successful?).to eq(true)

        payment.update!(mode: 'check', as_paid: true)
        expect(payment.successful?).to eq(true)

        payment.update!(mode: 'pos', as_paid: true)
        expect(payment.successful?).to eq(true)
      end
    end
    it 'returns false' do
      expect(payment.successful?).to eq(false)
    end
  end

  describe '#date_id' do
    it 'generates date_id from created_at' do
      payment = FactoryBot.create(:payment, created_at: '2021-01-01T09:25+01')
      expect(payment.date_id).to eq("202101010925#{payment.id}")
    end
  end

  describe '#tax_amount' do
    context 'when tax_rate = 20' do
      it 'returns valid amount' do
        payment = FactoryBot.create(:payment, amount: 3000)
        expect(payment.tax_rate).to eq(20)
        expect(payment.tax_amount).to eq(600)
      end
    end
    context 'when tax_rate different from 20' do
      it 'returns valid amount' do
        payment = FactoryBot.create(:payment, amount: 3000, tax_rate: 5.5)
        expect(payment.tax_rate).to eq(5.5)
        expect(payment.tax_amount).to eq(165)
      end
    end
  end

  describe '#amount_without_tax' do
    context 'when tax_rate = 20' do
      it 'returns valid amount' do
        payment = FactoryBot.create(:payment, amount: 3000)
        expect(payment.tax_rate).to eq(20)
        expect(payment.amount_without_tax).to eq(2400)
      end
    end
    context 'when tax_rate different from 20' do
      it 'returns valid amount' do
        payment = FactoryBot.create(:payment, amount: 3000, tax_rate: 5.5)
        expect(payment.tax_rate).to eq(5.5)
        expect(payment.amount_without_tax).to eq(2835)
      end
    end
  end

  describe '#mode_in_french' do
    let(:payment) { FactoryBot.create(:payment, mode: 'online') }
    it 'returns mode in french' do
      expect(payment.mode_in_french).to eq('CB en ligne')

      payment.update!(mode: 'cash')
      expect(payment.mode_in_french).to eq('Espèces')

      payment.update!(mode: 'check')
      expect(payment.mode_in_french).to eq('Chèque')
    end
  end
end
