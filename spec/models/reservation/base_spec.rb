require 'rails_helper'

RSpec.describe Reservation, type: :model do
  it 'has valid factory' do
    expect(FactoryBot.build(:reservation)).to be_valid
    expect(FactoryBot.create(:reservation)).to be_valid
  end

  it 'belongs to either client or company_client' do
    expect(FactoryBot.build(:reservation, client: nil)).not_to be_valid
    expect(FactoryBot.create(:reservation, client: FactoryBot.create(:client))).to be_valid
    expect(FactoryBot.create(:reservation, company_client: FactoryBot.create(:company_client))).to be_valid
  end

  it 'can belong to user' do
    expect(FactoryBot.build(:reservation, user: nil)).to be_valid
    expect(FactoryBot.create(:reservation, user: FactoryBot.create(:user))).to be_valid
  end

  it 'belongs to product_price' do
    expect(FactoryBot.build(:reservation, product_price: nil)).not_to be_valid
  end

  it 'can have start time' do
    expect(FactoryBot.build(:reservation, start_time: nil)).to be_valid
    expect(FactoryBot.build(:reservation, start_time: DateTime.current.to_date)).to be_valid
  end

  it 'has email_notification flag' do
    expect(FactoryBot.build(:reservation, email_notification: nil)).not_to be_valid
    expect(FactoryBot.build(:reservation, email_notification: false)).to be_valid
  end

  xit 'has first_time flag' do
    expect(FactoryBot.build(:reservation, first_time: nil)).not_to be_valid
    expect(FactoryBot.build(:reservation, first_time: false)).to be_valid
  end

  describe '#paid?' do
    let(:reservation) { FactoryBot.create(:reservation) }
    context 'when has valid payment' do
      it 'returns true' do
        payment = FactoryBot.create(:payment, bank_name: 'Crédit Agricole')
        reservation.update(payment: payment)
        expect(reservation.paid?).to eq(true)
      end
    end
    context 'when has payment but not successful' do
      it 'returns false' do
        payment = FactoryBot.create(:payment)
        reservation.update(payment: payment)
        expect(reservation.paid?).to eq(false)
      end
    end
    context 'when paid_by_credit = true' do
      it 'returns true' do
        expect(reservation.paid?).to eq(false)
        reservation.update(paid_by_credit: true)
        expect(reservation.paid?).to eq(true)
      end
    end
    it 'returns false' do
      expect(reservation.paid?).to eq(false)
    end
  end

  describe '#generate_amount' do
    let(:product_price) { FactoryBot.create(:product_price, total: 30) }
    let(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    context 'when coupon' do
      xit 'returns product price minus coupon discount' do
        coupon = FactoryBot.create(:coupon, percentage: false, value: 10)
        reservation.update(coupon: coupon)
        expect(reservation.amount).to eq(2000)
      end
    end
    xit 'returns product price times 100' do
      expect(reservation.amount).to eq(3000)
    end
  end

  describe '#slots_for' do
    let(:product) { FactoryBot.create(:product, duration: 60) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let(:reservation) { FactoryBot.create(:reservation, product_price: product_price) }
    context 'when duration is 60 minutes' do
      context 'when slot already taken by reservation' do
        it 'does not return slot' do
          start_time = '2020-01-01T09:00:00'
          FactoryBot.create(:reservation, product_price: product_price, start_time: start_time)
          expect(reservation.slots_for('2020-01-01')).not_to include('09:00')
        end
      end
      context 'when slot already taken by blocker' do
        context 'when blocker is not blocking' do
          it 'returns slot' do
            start_time = '2020-01-01T09:00:00'
            end_time = '2020-01-01T11:00:00'
            blocker = FactoryBot.create(:blocker, franchise: reservation.client.franchise, start_time: start_time, end_time: end_time, blocking: false)
            expect(reservation.slots_for('2020-01-01')).to eq([
              '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00',
            ])
          end
        end
        context 'when blocker is blocking' do
          it 'does not return slot' do
            start_time = '2020-01-01T09:00:00'
            end_time = '2020-01-01T11:00:00'
            blocker = FactoryBot.create(:blocker, franchise: reservation.client.franchise, start_time: start_time, end_time: end_time, blocking:true)
            expect(reservation.slots_for('2020-01-01')).not_to include('09:00')
            expect(reservation.slots_for('2020-01-01')).not_to include('09:30')
            expect(reservation.slots_for('2020-01-01')).not_to include('10:00')
            expect(reservation.slots_for('2020-01-01')).not_to include('10:30')
            expect(reservation.slots_for('2020-01-01')).to include('11:00')
          end
        end
      end
      it 'returns all hours' do
        expect(reservation.slots_for('2020-01-01')).to eq([
          '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00',
        ])
      end
    end
    context 'when duration is 30 minutes' do
      context 'when slot already taken by reservation' do
        it 'does not return slot' do
          product.update duration: 30
          start_time = '2020-01-01T09:30:00'
          FactoryBot.create(:reservation, product_price: product_price, start_time: start_time)
          expect(reservation.slots_for('2020-01-01')).not_to include('09:30')
        end
      end
      context 'when slot already taken by blocker' do
        context 'when blocker is not blocking' do
          it 'returns slot' do
            product.update duration: 30
            start_time = '2020-01-01T09:00:00'
            end_time = '2020-01-01T11:00:00'
            blocker = FactoryBot.create(:blocker, franchise: reservation.client.franchise, start_time: start_time, end_time: end_time, blocking: false)
            expect(reservation.slots_for('2020-01-01')).to eq([
              '08:00', '08:30',
              '09:00', '09:30',
              '10:00', '10:30',
              '11:00', '11:30',
              '12:00', '12:30',
              '13:00', '13:30',
              '14:00', '14:30',
              '15:00', '15:30',
              '16:00', '16:30',
              '17:00', '17:30',
              '18:00', '18:30',
              '19:00', '19:30',
              '20:00',
            ])
          end
        end
        context 'when blocker is blocking' do
          it 'does not return slot' do
            product.update duration: 30
            start_time = '2020-01-01T09:00:00'
            end_time = '2020-01-01T11:00:00'
            blocker = FactoryBot.create(:blocker, franchise: reservation.client.franchise, start_time: start_time, end_time: end_time, blocking: true)
            expect(reservation.slots_for('2020-01-01')).not_to include('09:00')
            expect(reservation.slots_for('2020-01-01')).not_to include('09:30')
            expect(reservation.slots_for('2020-01-01')).not_to include('10:00')
            expect(reservation.slots_for('2020-01-01')).not_to include('10:30')
            expect(reservation.slots_for('2020-01-01')).to include('11:00')
          end
        end
      end
      it 'returns all half hours' do
        product.update duration: 30
        expect(reservation.slots_for('2020-01-01')).to eq([
          '08:00', '08:30',
          '09:00', '09:30',
          '10:00', '10:30',
          '11:00', '11:30',
          '12:00', '12:30',
          '13:00', '13:30',
          '14:00', '14:30',
          '15:00', '15:30',
          '16:00', '16:30',
          '17:00', '17:30',
          '18:00', '18:30',
          '19:00', '19:30',
          '20:00',
        ])
      end
    end
    context 'when slot already taken by reservation' do
      it 'does not return slot' do
        start_time = '2020-01-01T09:00:00'
        FactoryBot.create(:reservation, product_price: product_price, start_time: start_time)
        expect(reservation.slots_for('2020-01-01')).not_to include('09:00')
      end
    end
  end

  describe '#refund' do
    let(:reservation) { FactoryBot.create(:reservation) }
    context 'when reservation already refunded' do
      it 'does not create any credit' do
        reservation.update!(refunded: true)
        expect do
          reservation.refund
        end.not_to change(reservation.client.credits, :count)
        expect do
          reservation.refund
        end.not_to change(reservation.client.credits, :count)
      end
    end
    context 'when paid_by_credit == false' do
      it 'does not create credit for client' do
        expect do
          reservation.refund
        end.not_to change(reservation.client.credits, :count)
      end
      it 'creates payment' do
        expect do
          reservation.refund
        end.to change(Payment, :count).by(1)
        expect(Payment.last.client).to eq(reservation.client)
        expect(Payment.last.amount).to eq(-reservation.product_price.product.product_prices.find_by(session_count: 1, professionnal: false).total*100)
        expect(Payment.last.product_name).to eq(reservation.product_price.product.name)
        expect(Payment.last.as_paid).to eq(true)
      end
    end
    context 'when paid_by_credit == true' do
      before(:each) do
        reservation.update!(paid_by_credit: true)
      end
      it 'creates credit for client' do
        expect do
          reservation.refund
        end.to change(reservation.client.credits, :count).by(1)
        expect(reservation.client.credits.first.product).to eq(reservation.product_price.product)
      end
      it 'does not create payment' do
        expect do
          reservation.refund
        end.not_to change(Payment, :count)
      end
    end
    it 'sets reservation#refunded to true' do
      expect do
        reservation.refund
      end.to change(reservation, :refunded).from(false).to(true)
    end
  end
end
