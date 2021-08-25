class CampaignsController < ApplicationController
  before_action :authenticate_admin
  before_action :get_campaigns, only: [:index, :create]
  before_action :find_campaign, only: [:show, :update, :destroy, :send_test, :send_now]

  def index
    @campaign = current_user.franchise.campaigns.new
    @campaigns = @campaigns.order(created_at: :desc)
  end

  def show
    if current_user.superuser
      @products = Product.all
    else
      @products = current_user.franchise.products
    end
  end

  def create
    @campaign = Campaign.new campaign_params
    @campaign.franchise_id = current_user.franchise.id if @campaign.franchise_id.nil?
    if @campaign.save
      redirect_to campaigns_path
    else
      render :index, campaign: @campaign
    end
  end

  def update
    if @campaign.update campaign_params
      redirect_to @campaign
    else
      render :show, campaign: @campaign
    end
  end

  def destroy
    @campaign.destroy
    head :no_content
  end

  def send_test
    if @campaign.sms == false
      @campaign.send_test_email(params[:campaign][:email])
      redirect_to @campaign
    end
  end

  def send_now
    if @campaign.sms == false
      @campaign.send_now
      head :no_content
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:franchise_id, :name, :campaign_template_id, :body, :sms, :draft, :email, { :recipients =>  [] }, { :filters => {} })
  end

  def get_campaigns
    if current_user.superuser
      @franchises = Franchise.all.order(:name)
      if params[:franchise_id]
        @campaigns = Campaign.all.where(franchise_id: params[:franchise_id])
        @templates = CampaignTemplate.all.where(franchise_id: params[:franchise_id])
      else
        @campaigns = Campaign.all
        @templates = CampaignTemplate.all
      end
    else
      @campaigns = current_user.franchise.campaigns
      @templates = current_user.franchise.campaign_templates
    end
  end

  def find_campaign
    if current_user.superuser
      @campaign = Campaign.find params[:id]
    else
      @campaign = current_user.franchise.campaigns.find(params[:id])
    end
  end
end
