class AddColumnsToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :subject, :string, null: false
    add_column :campaigns, :sendinblue_campaign_id, :integer
  end
end
