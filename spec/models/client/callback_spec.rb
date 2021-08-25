require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'before_save #format_objectives' do
    it 'gets rid of blank strings' do
      client = FactoryBot.create(:client, objectives: ['', 'sport'])
      expect(client.objectives).to eq(['sport'])
    end
  end
end
