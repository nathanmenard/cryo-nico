class AddInfosToCompanyClients < ActiveRecord::Migration[6.0]
  def change
    add_column :company_clients, :password_digest, :string
    add_column :company_clients, :last_logged_at, :datetime
  end
end
