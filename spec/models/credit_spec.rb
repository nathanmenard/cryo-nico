require 'rails_helper'

RSpec.describe Credit, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:credit)).to be_valid
    expect(FactoryBot.create(:credit)).to be_valid
  end

  it 'can belong to client' do
    expect(FactoryBot.create(:credit, client: nil)).to be_valid
    expect(FactoryBot.create(:credit, client: FactoryBot.create(:client))).to be_valid
  end

  it 'can belong to company_client' do
    expect(FactoryBot.create(:credit, company_client: nil)).to be_valid
    expect(FactoryBot.create(:credit, company_client: FactoryBot.create(:company_client))).to be_valid
  end

  it 'belongs to product' do
    expect(FactoryBot.build(:credit, product: nil)).not_to be_valid
  end
end
