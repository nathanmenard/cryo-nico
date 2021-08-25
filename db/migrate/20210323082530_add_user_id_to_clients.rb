class AddUserIdToClients < ActiveRecord::Migration[6.1]
  def change
    add_reference :clients, :user, null: true, index: true, foreign_key: true
  end
end
