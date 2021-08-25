require 'rails_helper'

RSpec.describe Client, type: :model do
  describe '.birthday_today' do
    it 'clients whose birthday is today' do
      client_a = FactoryBot.create(:client, birth_date: Date.today - 20.years)
      client_b = FactoryBot.create(:client, birth_date: Date.today - 30.years)
      client_c = FactoryBot.create(:client, birth_date: Date.today + 10.days - 30.years)
      expect(Client.birthday_today).to eq([client_a, client_b])
    end
  end

  describe '.subscribers' do
    it 'clients that have at least one subscription' do
      client_a = FactoryBot.create(:client)
      client_b = FactoryBot.create(:client)
      client_c = FactoryBot.create(:client)
      FactoryBot.create(:subscription, client: client_a)
      expect(Client.subscribers).to eq([client_a])
    end
  end
end
