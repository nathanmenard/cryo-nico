require 'rails_helper'

RSpec.describe Blocker, type: :model do
  it 'has valid factory' do
    expect(FactoryBot.build(:blocker)).to be_valid
    expect(FactoryBot.create(:blocker)).to be_valid
  end

  it 'belongs to user' do
    expect(FactoryBot.build(:blocker, user: nil)).not_to be_valid
  end

  it 'belongs to franchise' do
    expect(FactoryBot.build(:blocker, franchise: nil)).not_to be_valid
  end

  it 'belongs to room' do
    expect(FactoryBot.build(:blocker, room: nil)).not_to be_valid
  end

  it 'can belong to blocker' do
    expect(FactoryBot.build(:blocker, blocker: nil)).to be_valid
    expect(FactoryBot.build(:blocker, global: true, blocker: FactoryBot.create(:blocker))).to be_valid
  end

  describe '#duration' do
    let(:blocker) { FactoryBot.create(:blocker, start_time: '2020-01-01T09:00:00', end_time: '2020-01-01T10:00:00') }
    it 'returns duration in minutes' do
      expect(blocker.duration).to eq(60)
    end
  end
end
