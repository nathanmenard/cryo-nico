class AddInstagramTokenToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :instagram_token, :text
  end
end
