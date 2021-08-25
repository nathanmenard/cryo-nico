class AddLoyaltyToCoupons < ActiveRecord::Migration[6.1]
  def change
    add_column :coupons, :loyalty, :boolean, default: false
  end
end
