require 'rails_helper'

RSpec.describe SurveyQuestionsController, type: :controller do
  let(:current_user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room, franchise: current_user.franchise) }
  let(:product) { FactoryBot.create(:product, room: room) }
  let(:survey) { FactoryBot.create(:survey, product: product) }

  describe 'POST :create' do
    context 'when not logged in' do
      it 'redirects to login form' do
        post :create, params: { survey_id: survey.id, survey_questions: [{ body: 'Question A' }, { body: 'Question B' }] }
        expect(response).to redirect_to('/admin')
      end
    end
    context 'when invalid payload' do
      it 'displays errors' do
        expect {
          session[:user_id] = current_user.id
          post :create, params: { survey_id: survey.id, survey_questions: [{ body: '' }, { body: '' }] }
        }.not_to change(survey.survey_questions, :count)
      end
    end
    it 'updates existing survey questions' do
      survey_question = FactoryBot.create(:survey_question, survey: survey)
      session[:user_id] = current_user.id
      post :create, params: { survey_id: survey.id, survey_questions: [{ id: survey_question.id, body: 'Updated Question A' }, { body: 'Question B' }] }
      expect(survey.survey_questions.reload.count).to eq(2)
      expect(survey_question.reload.body).to eq('Updated Question A')
    end
    it 'creates survey question' do
      session[:user_id] = current_user.id
      post :create, params: { survey_id: survey.id, survey_questions: [{ body: 'Question A' }, { body: 'Question B' }] }
      expect(survey.survey_questions.count).to eq(2)
      survey_ids = SurveyQuestion.pluck(:survey_id)
      expect(survey_ids).to eq([survey.id, survey.id])
      bodys = SurveyQuestion.pluck(:body)
      expect(bodys).to eq(['Question A', 'Question B'])
    end
  end
end
