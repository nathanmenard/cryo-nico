class AddFirstTimeToProductPrices < ActiveRecord::Migration[6.1]
  def change
    add_column :product_prices, :first_time, :boolean, null: false, default: false
  end
end
