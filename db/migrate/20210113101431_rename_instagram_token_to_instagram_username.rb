class RenameInstagramTokenToInstagramUsername < ActiveRecord::Migration[6.0]
  def change
    rename_column :franchises, :instagram_token, :instagram_username
  end
end
