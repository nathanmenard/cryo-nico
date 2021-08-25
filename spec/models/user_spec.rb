require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:user)).to be_valid
    expect(FactoryBot.create(:user)).to be_valid
  end

  it 'has a first_name' do
    expect(FactoryBot.build(:user, first_name: nil)).not_to be_valid
  end

  it 'has a last_name' do
    expect(FactoryBot.build(:user, last_name: nil)).not_to be_valid
  end

  it 'has a unique email' do
    expect(FactoryBot.create(:user, email: 'said@gmail.com')).to be_valid
    expect(FactoryBot.build(:user, email: 'said@gmail.com')).not_to be_valid
  end

  it 'has a valid email' do
    expect(FactoryBot.create(:user, email: 'said@gmail.com')).to be_valid
    expect(FactoryBot.build(:user, email: 'said@gmail')).not_to be_valid
    expect(FactoryBot.build(:user, email: 'saidgmail')).not_to be_valid
  end

  it 'can have a password' do
    user = FactoryBot.create(:user, password: 'azerty')
    expect(user).to be_valid
    expect(user.authenticate('invalid password')).to eq(false)
    expect(user.authenticate('azerty')).to eq(user)
  end
  
  it 'belongs to franchise' do
    expect(FactoryBot.build(:user, franchise: nil)).not_to be_valid
  end
end
