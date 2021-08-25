require 'rails_helper'

RSpec.describe SurveyQuestion, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:survey_question)).to be_valid
    expect(FactoryBot.create(:survey_question)).to be_valid
  end

  it 'belongs to survey' do
    expect(FactoryBot.build(:survey_question, survey: nil)).not_to be_valid
  end

  it 'has body' do
    expect(FactoryBot.build(:survey_question, body: nil)).not_to be_valid
  end
end
