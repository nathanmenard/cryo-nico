class AddFiltersToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :filters, :json
  end
end
