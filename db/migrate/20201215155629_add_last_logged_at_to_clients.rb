class AddLastLoggedAtToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :last_logged_at, :datetime
  end
end
