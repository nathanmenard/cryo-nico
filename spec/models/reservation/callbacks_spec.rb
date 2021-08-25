require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'before_save #check_room_availability' do
    let(:room) { FactoryBot.create(:room, capacity: 2) }
    let(:product) { FactoryBot.create(:product, room: room) }
    let(:product_price) { FactoryBot.create(:product_price, product: product) }
    let(:reservation) { FactoryBot.create(:reservation, product_price: product_price, start_time: '2010-01-01T:10:00') }
    let(:reservation_2) { FactoryBot.create(:reservation, product_price: product_price, start_time: '2010-01-01T:10:00') }
    context 'when new reservation' do
      context 'when does not have start_time' do
        it 'skips availability check' do
          expect(reservation).to be_valid
          expect(reservation_2).to be_valid
          expect do
            FactoryBot.create(:reservation, product_price: product_price, start_time: nil)
          end.not_to raise_error
        end
      end
      context 'when it has start_time' do
        it 'raises exception if time not available' do
          expect(reservation).to be_valid
          expect(reservation_2).to be_valid
          expect do
            FactoryBot.create(:reservation, product_price: product_price, start_time: '2010-01-01T:10:00')
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
        it 'allows admin to double book a room' do
          expect(reservation).to be_valid
          expect(reservation_2).to be_valid
          expect(FactoryBot.create(:reservation, product_price: product_price, start_time: '2010-01-01T:10:00', user: FactoryBot.create(:user))).to be_valid
        end
      end
    end
    context 'when existing reservation' do
      it 'does not raise error' do
        expect(reservation).to be_valid
        expect(reservation_2).to be_valid
        expect {
          reservation_2.update! start_time: reservation_2.start_time
        }.not_to raise_error
      end
    end
  end

  describe 'before_save #generate_random_id' do
    it 'generates 6 digit random id' do
      10.times do
        expect(FactoryBot.build(:reservation)).to be_valid
        expect(FactoryBot.create(:reservation)).to be_valid
      end
    end
  end

  describe 'before_save #round_minutes' do
    let(:reservation) { FactoryBot.create(:reservation) }
    context 'when minutes is not half hour' do
      it 'rounds to neirest half hour' do
        reservation = FactoryBot.create(:reservation, start_time: '2021-01-01T08:10')
        expect(reservation.reload.start_time).to eq('2021-01-01T08:00+01')

        reservation.update!(start_time: '2021-01-01T08:15')
        expect(reservation.reload.start_time).to eq('2021-01-01T08:00+01')

        reservation.update!(start_time: '2021-01-01T08:30')
        expect(reservation.reload.start_time).to eq('2021-01-01T08:30+01')

        reservation.update!(start_time: '2021-01-01T08:40')
        expect(reservation.reload.start_time).to eq('2021-01-01T08:30+01')

        reservation.update!(start_time: '2021-01-01T08:45')
        expect(reservation.reload.start_time).to eq('2021-01-01T09:00+01')

        reservation.update!(start_time: '2021-01-01T08:00')
        expect(reservation.reload.start_time).to eq('2021-01-01T08:00+01')
      end
    end
  end

  describe 'before_create #generate_first_time' do
    context 'when first time' do
      it 'sets first_time as true' do
        reservation = FactoryBot.create(:reservation)
        expect(reservation.first_time).to eq(true)
      end
    end
    context 'when not first time' do
      it 'sets first_time as false' do
        reservation = FactoryBot.create(:reservation)
        expect(reservation.first_time).to eq(true)
        reservation_2 = FactoryBot.create(:reservation, product_price: reservation.product_price, client: reservation.client)
        expect(reservation_2.first_time).to eq(false)
      end
    end
  end
end
