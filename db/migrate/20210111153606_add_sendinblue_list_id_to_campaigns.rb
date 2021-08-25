class AddSendinblueListIdToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :sendinblue_list_id, :integer
  end
end
