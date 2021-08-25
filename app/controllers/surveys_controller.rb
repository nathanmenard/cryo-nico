class SurveysController < ApplicationController
  before_action :authenticate_admin
  before_action :get_surveys, only: [:index, :create]
  before_action :find_survey, only: [:show, :update, :destroy]

  def index
    @survey = current_user.franchise.surveys.new
  end

  def show
  end

  def create
    @survey = Survey.new survey_params
    if @survey.save
      redirect_to surveys_path
    else
      render :index, survey: @survey
    end
  end

  def update
    if @survey.update survey_params
      redirect_to @survey
    else
      render :show, survey: @survey
    end
  end

  def destroy
    @survey.destroy!
    head :no_content
  end

  private

  def survey_params
    params.require(:survey).permit(:product_id, :franchise_id, :name)
  end

  def get_surveys
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @surveys = Survey.all.where(franchise_id: params[:franchise_id])
      else
        @surveys = Survey.all
      end
    else
      @surveys = current_user.franchise.surveys
    end
  end

  def find_survey
    if current_user.superuser
      @survey = Survey.find params[:id]
    else
      @survey = Survey.find(params[:id])
      if @survey.product.room.franchise != current_user.franchise
        head :not_found and return
      end
    end
  end
end
