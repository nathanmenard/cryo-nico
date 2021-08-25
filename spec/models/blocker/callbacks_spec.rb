require 'rails_helper'

RSpec.describe Blocker, type: :model do
  describe 'after_create #clone_if_global' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let!(:room_1) { FactoryBot.create(:room, franchise: franchise) }
    let!(:room_2) { FactoryBot.create(:room, franchise: franchise) }
    context 'when blocker is global' do
      it 'duplicates blocker for all rooms' do
        FactoryBot.create(:blocker, room: room_1, global: true)
        expect(Blocker.count).to eq(2)
      end
    end
    context 'when blocker is not global' do
      it 'creates only blocker' do
        FactoryBot.create(:blocker, room: room_1, global: false)
        expect(Blocker.count).to eq(1)
      end
    end
  end

  describe 'after_update #update_children' do
    let(:franchise) { FactoryBot.create(:franchise) }
    let!(:room_1) { FactoryBot.create(:room, franchise: franchise) }
    let!(:room_2) { FactoryBot.create(:room, franchise: franchise) }
    context 'when blocker is global' do
      it 'updates children blockers' do
        blocker = FactoryBot.create(:blocker, room: room_1, global: true, blocking: false)
        blocker.update!(blocking: true)
        expect(Blocker.count).to eq(2)
        expect(Blocker.all.pluck(:blocking).uniq).to eq([true])
        expect(Blocker.last.blocker).to eq(blocker)
      end
    end
  end

  describe 'before_save #round_minutes' do
    let(:blocker) { FactoryBot.create(:blocker) }
    context 'when minutes is not half hour' do
      it 'rounds to neirest half hour' do
        blocker = FactoryBot.create(:blocker, start_time: '2021-01-01T08:10')
        expect(blocker.reload.start_time).to eq('2021-01-01T08:00+01')

        blocker.update!(start_time: '2021-01-01T08:15')
        expect(blocker.reload.start_time).to eq('2021-01-01T08:00+01')

        blocker.update!(start_time: '2021-01-01T08:30')
        expect(blocker.reload.start_time).to eq('2021-01-01T08:30+01')

        blocker.update!(start_time: '2021-01-01T08:40')
        expect(blocker.reload.start_time).to eq('2021-01-01T08:30+01')

        blocker.update!(start_time: '2021-01-01T08:45')
        expect(blocker.reload.start_time).to eq('2021-01-01T09:00+01')

        blocker.update!(start_time: '2021-01-01T08:00')
        expect(blocker.reload.start_time).to eq('2021-01-01T08:00+01')
      end
    end
  end
end
