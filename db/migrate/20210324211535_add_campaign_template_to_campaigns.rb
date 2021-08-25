class AddCampaignTemplateToCampaigns < ActiveRecord::Migration[6.1]
  def change
    remove_column :campaigns, :subject
    add_reference :campaigns, :campaign_template, null: true, index: true, foreign_key: true
  end
end
