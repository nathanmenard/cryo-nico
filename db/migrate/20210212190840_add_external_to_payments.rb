class AddExternalToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :external, :boolean, null: false
  end
end
