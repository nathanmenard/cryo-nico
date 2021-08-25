require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it 'has valid factory' do
    expect(FactoryBot.build(:subscription)).to be_valid
    expect(FactoryBot.create(:subscription)).to be_valid
  end

  it 'belongs to subscription plan' do
    expect(FactoryBot.build(:subscription, subscription_plan: nil)).not_to be_valid
  end

  it 'belongs to client' do
    expect(FactoryBot.build(:subscription, client: nil)).not_to be_valid
  end

  xit 'has valid status' do
    expect(FactoryBot.build(:subscription, status: nil)).not_to be_valid
  end

  describe '#cancel' do
    context 'when already canceled' do
      it 'does not update subscription' do
        subscription = FactoryBot.create(:subscription, status: 'canceled')
        expect do
          subscription.cancel
        end.not_to change(subscription, :updated_at)
      end
    end
    it 'sets status as canceled' do
      subscription = FactoryBot.create(:subscription)
      expect do
        subscription.cancel
      end.to change(subscription, :status).from('active').to('canceled')
    end
  end

  describe '#active?' do
    context 'when status != active' do
      it 'returns false' do
        subscription = FactoryBot.create(:subscription, status: 'canceled_by_admin')
        expect(subscription.active?).to eq(false)

        subscription.update!(status: 'canceled_by_user')
        expect(subscription.active?).to eq(false)
      end
    end
    context 'when status = active' do
      it 'returns true' do
        subscription = FactoryBot.create(:subscription, status: 'active')
        expect(subscription.active?).to eq(true)
      end
    end
  end
end
