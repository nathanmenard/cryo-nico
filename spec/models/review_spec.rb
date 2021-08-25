require 'rails_helper'

RSpec.describe Review, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:review)).to be_valid
    expect(FactoryBot.create(:review)).to be_valid
  end

  it 'belongs to a product' do
    expect(FactoryBot.build(:review, product: nil)).not_to be_valid
    expect(FactoryBot.create(:review, product: FactoryBot.create(:product))).to be_valid
  end

  it 'belongs to either a client of a company_client' do
    expect(FactoryBot.build(:review, client: nil)).not_to be_valid
    expect(FactoryBot.create(:review, client: FactoryBot.create(:client))).to be_valid
    expect(FactoryBot.create(:review, company_client: FactoryBot.create(:company_client))).to be_valid
  end

  it 'has a body' do
    expect(FactoryBot.build(:review, body: nil)).not_to be_valid
    expect(FactoryBot.create(:review, body: 'Hello')).to be_valid
  end

  it 'can have a published flag' do
    expect(FactoryBot.create(:review, published: nil)).to be_valid
    expect(FactoryBot.create(:review, published: true)).to be_valid
    expect(FactoryBot.create(:review, published: false)).to be_valid
  end
end
