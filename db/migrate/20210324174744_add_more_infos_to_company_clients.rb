class AddMoreInfosToCompanyClients < ActiveRecord::Migration[6.1]
  def change
    add_column :company_clients, :male, :boolean
    add_column :company_clients, :birth_date, :text
    add_column :company_clients, :objectives, :string, array: true, default: []
    add_column :company_clients, :address, :text
    add_column :company_clients, :zip_code, :string
    add_column :company_clients, :city, :string
    add_column :company_clients, :boolean, :boolean
  end
end
