require 'rails_helper'

RSpec.describe Survey, type: :model do
  it 'has valid factory' do
    expect(FactoryBot.build(:survey)).to be_valid
    expect(FactoryBot.create(:survey)).to be_valid
  end

  it 'belongs to product' do
    expect(FactoryBot.build(:survey, product: nil)).not_to be_valid
  end 

  it 'has name' do
    expect(FactoryBot.build(:survey, name: nil)).not_to be_valid
  end 
end
