class AddModeToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :mode, :string
  end
end
