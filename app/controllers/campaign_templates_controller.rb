class CampaignTemplatesController < ApplicationController
  before_action :authenticate_admin

  def upsert
    CampaignTemplate.fetch(current_user.franchise)
    redirect_to campaigns_path
  end
end
