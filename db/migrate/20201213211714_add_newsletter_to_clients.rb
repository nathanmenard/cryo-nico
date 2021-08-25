class AddNewsletterToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :newsletter, :boolean
  end
end
