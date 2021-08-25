class AddClientIdToClients < ActiveRecord::Migration[6.0]
  def change
    add_reference :clients, :client, null: true, index: true, foreign_key: true
  end
end
