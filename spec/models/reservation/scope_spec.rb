require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe '.scheduled' do
    it 'ignores reservations without start time' do
      reservation = FactoryBot.create(:reservation, start_time: nil)
      reservation_2 = FactoryBot.create(:reservation, start_time: Date.today)
      expect(Reservation.scheduled).to eq([reservation_2])
    end
    it 'returns reservations where canceled = false' do
      reservation = FactoryBot.create(:reservation, canceled: true)
      reservation_2 = FactoryBot.create(:reservation)
      expect(Reservation.scheduled).to eq([reservation_2])
    end
  end

  describe '.paid' do
    it 'returns paid reservations' do
      payment = FactoryBot.create(:payment, bank_name: 'Crédit Agricole')
      reservation = FactoryBot.create(:reservation, payment: payment)
      reservation_2 = FactoryBot.create(:reservation)
      expect(Reservation.paid).to eq([reservation])
    end
  end

  describe '.finished_yesterday' do
    it 'returns all reservations finished yesterday' do
      reservation_a = FactoryBot.create(:reservation, start_time: Date.today - 1.day)
      reservation_b = FactoryBot.create(:reservation, start_time: Date.today - 2.day)
      reservation_c = FactoryBot.create(:reservation, start_time: Date.today)
      reservation_d = FactoryBot.create(:reservation, start_time: Date.today + 1.day)
      expect(Reservation.finished_yesterday).to eq([reservation_a])
    end
  end

  describe '.find_by_private_key' do
    let(:reservation) { FactoryBot.create(:reservation) }
    context 'when does not exist' do
      it 'raises record not found' do
        expect {
          Reservation.find_by_private_key('invalid key')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    it 'returns company client' do
      expect(Reservation.find_by_private_key(reservation.private_key)).to eq(reservation)
    end
  end

  describe '.by_time' do
    it 'returns reservation matching hour and minutes' do
      reservation_a = FactoryBot.create(:reservation, start_time: '2021-01-01T08:30:00+1')
      reservation_b = FactoryBot.create(:reservation, start_time: '2021-01-01T08:00:00+1')
      reservation_c = FactoryBot.create(:reservation, start_time: '2021-01-02T08:30:00+1')
      expect(Reservation.by_time('08:30').pluck(:id).sort).to eq([reservation_a.id, reservation_c.id].sort)
    end
  end

  describe '.today' do
    it 'returns reservations from today' do
      reservation_a = FactoryBot.create(:reservation, start_time: Date.today)
      reservation_b = FactoryBot.create(:reservation, start_time: Date.today-1.day)
      reservation_c = FactoryBot.create(:reservation, start_time: Date.today+1.day)
      expect(Reservation.today).to eq([reservation_a])
    end
  end
end
