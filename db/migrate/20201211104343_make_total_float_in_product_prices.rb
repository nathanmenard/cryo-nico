class MakeTotalFloatInProductPrices < ActiveRecord::Migration[6.0]
  def change
    change_column :product_prices, :total, :float
  end
end
