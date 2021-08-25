require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:comment)).to be_valid
    expect(FactoryBot.create(:comment)).to be_valid
  end

  it 'belongs to a user' do
    expect(FactoryBot.build(:comment, user: nil)).not_to be_valid
    expect(FactoryBot.create(:comment, user: FactoryBot.create(:user))).to be_valid
  end

  it 'belongs to a client' do
    expect(FactoryBot.build(:comment, client: nil)).not_to be_valid
    expect(FactoryBot.create(:comment, client: FactoryBot.create(:client))).to be_valid
  end

  it 'has a body' do
    expect(FactoryBot.build(:comment, body: nil)).not_to be_valid
    expect(FactoryBot.create(:comment, body: 'Lorem Ipsum..')).to be_valid
  end
end
