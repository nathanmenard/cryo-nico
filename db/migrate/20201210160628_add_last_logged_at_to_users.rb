class AddLastLoggedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_logged_at, :datetime
  end
end
