class SurveyQuestionsController < ApplicationController
  before_action :authenticate_admin

  def create
    @survey = Survey.find(params[:survey_id])
    request.params[:survey_questions].each do |survey_question_params|
      if survey_question_params[:id]
        @survey_question = @survey.survey_questions.find(survey_question_params[:id])
        @survey_question.update(survey_question_params)
      else
        @survey_question = @survey.survey_questions.new(survey_question_params)
        @survey_question.save
      end
    end
    redirect_to @survey
  end
end
