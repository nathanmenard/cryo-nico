class AddProductNameToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :product_name, :string, null: false
  end
end
