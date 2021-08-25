require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:company)).to be_valid
    expect(FactoryBot.create(:company)).to be_valid
  end

  it 'has a name' do
    expect(FactoryBot.build(:company, name: nil)).not_to be_valid
  end

  it 'has an email' do
    expect(FactoryBot.build(:company, email: nil)).not_to be_valid
  end

  it 'has a phone' do
    expect(FactoryBot.build(:company, phone: nil)).not_to be_valid
  end

  it 'has an address' do
    expect(FactoryBot.build(:company, address: nil)).not_to be_valid
  end

  it 'has a zip_code' do
    expect(FactoryBot.build(:company, zip_code: nil)).not_to be_valid
  end

  it 'has a city' do
    expect(FactoryBot.build(:company, city: nil)).not_to be_valid
  end

  it 'has a siret' do
    expect(FactoryBot.build(:company, siret: nil)).not_to be_valid
  end

  it 'has a valid email' do
    expect(FactoryBot.create(:company, email: 'said@gmail.com')).to be_valid
    expect(FactoryBot.build(:company, email: 'said@gmail')).not_to be_valid
    expect(FactoryBot.build(:company, email: 'saidgmail')).not_to be_valid
  end

  it 'has a valid phone' do
    expect(FactoryBot.create(:company, phone: '0620853909')).to be_valid
    expect(FactoryBot.build(:company, phone: '06.20.85.39.09')).not_to be_valid
    expect(FactoryBot.build(:company, phone: '062085390')).not_to be_valid
    expect(FactoryBot.build(:company, phone: 'invalid phone_number')).not_to be_valid
  end

  it 'has a valid zip_code' do
    expect(FactoryBot.create(:company, zip_code: '51100')).to be_valid
    expect(FactoryBot.build(:company, zip_code: '5110')).not_to be_valid
    expect(FactoryBot.build(:company, zip_code: 'invalid zip_code_number')).not_to be_valid
  end

  it 'has a valid siret' do
    expect(FactoryBot.create(:company, siret: '81214811200012')).to be_valid
    expect(FactoryBot.build(:company, siret: '5110')).not_to be_valid
    expect(FactoryBot.build(:company, siret: 'invalid siret_number')).not_to be_valid
  end
end
