class AddAsPaidToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :as_paid, :boolean
  end
end
