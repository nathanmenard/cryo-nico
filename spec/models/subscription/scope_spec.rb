require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe '.active' do
    it 'returns subscription with status = active' do
      subscription = FactoryBot.create(:subscription, status: 'canceled_by_user')
      subscription_2 = FactoryBot.create(:subscription, status: 'canceled_by_admin')
      subscription_3 = FactoryBot.create(:subscription, status: 'active')
      expect(Subscription.active).to eq([subscription_3])
    end
  end
end
