class AddTaxRateToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :tax_rate, :float, default: 20
  end
end
