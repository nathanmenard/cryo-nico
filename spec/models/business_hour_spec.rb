require 'rails_helper'

RSpec.describe BusinessHour, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:business_hour)).to be_valid
    expect(FactoryBot.create(:business_hour)).to be_valid
  end

  it 'has valid day' do
    days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    days.each do |day|
      expect(FactoryBot.build(:business_hour, day: day)).to be_valid
    end
    expect(FactoryBot.build(:business_hour, day: 'Sunday')).not_to be_valid
  end

  describe '#morning_start_time' do
    context 'when has half hour' do
      it 'display hour & minutes' do
        business_hour = FactoryBot.create(:business_hour, morning_start_time: '10:30')
        expect(business_hour.morning_start_time).to eq('10:30')
      end
    end
    context 'when does not have half hour' do
      it 'display hour only' do
        business_hour = FactoryBot.create(:business_hour, morning_start_time: '10:00')
        expect(business_hour.morning_start_time).to eq('10h')
      end
    end
  end

  describe '#morning_end_time' do
    context 'when has half hour' do
      it 'display hour & minutes' do
        business_hour = FactoryBot.create(:business_hour, morning_end_time: '10:30')
        expect(business_hour.morning_end_time).to eq('10:30')
      end
    end
    context 'when does not have half hour' do
      it 'display hour only' do
        business_hour = FactoryBot.create(:business_hour, morning_end_time: '10:00')
        expect(business_hour.morning_end_time).to eq('10h')
      end
    end
  end

  describe '#afternoon_start_time' do
    context 'when has half hour' do
      it 'display hour & minutes' do
        business_hour = FactoryBot.create(:business_hour, afternoon_start_time: '10:30')
        expect(business_hour.afternoon_start_time).to eq('10:30')
      end
    end
    context 'when does not have half hour' do
      it 'display hour only' do
        business_hour = FactoryBot.create(:business_hour, afternoon_start_time: '10:00')
        expect(business_hour.afternoon_start_time).to eq('10h')
      end
    end
  end

  describe '#afternoon_end_time' do
    context 'when has half hour' do
      it 'display hour & minutes' do
        business_hour = FactoryBot.create(:business_hour, afternoon_end_time: '10:30')
        expect(business_hour.afternoon_end_time).to eq('10:30')
      end
    end
    context 'when does not have half hour' do
      it 'display hour only' do
        business_hour = FactoryBot.create(:business_hour, afternoon_end_time: '10:00')
        expect(business_hour.afternoon_end_time).to eq('10h')
      end
    end
  end
end
