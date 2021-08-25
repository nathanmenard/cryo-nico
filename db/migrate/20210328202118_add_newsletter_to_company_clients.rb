class AddNewsletterToCompanyClients < ActiveRecord::Migration[6.1]
  def change
    add_column :company_clients, :newsletter, :boolean
  end
end
