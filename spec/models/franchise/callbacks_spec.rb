require 'rails_helper'

RSpec.describe Franchise, type: :model do
  describe 'after_create #create_business_hours' do
    it 'creates business hours' do
      expect do
        FactoryBot.create(:franchise)
      end.to change(BusinessHour, :count).by(6)
      expect(BusinessHour.all.pluck(:franchise_id).uniq).to eq([Franchise.last.id])
    end
  end
end
