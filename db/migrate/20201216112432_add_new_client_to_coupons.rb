class AddNewClientToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :new_client, :boolean, default: false
  end
end
