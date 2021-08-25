class AddObjectivesToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :objectives, :string, array: true, default: []
    add_column :clients, :address, :text
    add_column :clients, :zip_code, :string
    add_column :clients, :city, :string
    add_column :clients, :comment, :text
  end
end
