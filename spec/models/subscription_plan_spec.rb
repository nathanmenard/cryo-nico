require 'rails_helper'

RSpec.describe SubscriptionPlan, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:subscription_plan)).to be_valid
    expect(FactoryBot.create(:subscription_plan)).to be_valid
  end

  it 'belongs to product' do
    expect(FactoryBot.build(:subscription_plan, product: nil)).not_to be_valid
  end

  xit 'has unique session count for product' do
    product = FactoryBot.create(:product)
    expect(FactoryBot.create(:subscription_plan, product: product, session_count: 4)).to be_valid
    expect(FactoryBot.build(:subscription_plan, product: product, session_count: 4)).not_to be_valid
  end
end
