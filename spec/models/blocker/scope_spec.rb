require 'rails_helper'

RSpec.describe Blocker, type: :model do
  describe '.today' do
    it 'returns blockers from today' do
      blocker_a = FactoryBot.create(:blocker, start_time: Date.today)
      blocker_b = FactoryBot.create(:blocker, start_time: Date.today-1.day)
      blocker_c = FactoryBot.create(:blocker, start_time: Date.today+1.day)
      expect(Blocker.today).to eq([blocker_a])
    end
  end

  describe '.by_time' do
    it 'returns blockers matching hour and minutes' do
      blocker_a = FactoryBot.create(:blocker, start_time: '2021-01-01T08:30:00+1')
      blocker_b = FactoryBot.create(:blocker, start_time: '2021-01-01T08:00:00+1')
      blocker_c = FactoryBot.create(:blocker, start_time: '2021-01-02T08:30:00+1')
      expect(Blocker.by_time('08:30')).to eq([blocker_a, blocker_c])
    end
  end
end
