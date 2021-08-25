class AddCompanyClientIdToCompanyClients < ActiveRecord::Migration[6.0]
  def change
    add_reference :company_clients, :company_client, null: true, index: true, foreign_key: true
  end
end
