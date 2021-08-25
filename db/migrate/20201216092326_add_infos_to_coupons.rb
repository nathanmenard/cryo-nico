class AddInfosToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :male, :boolean
    add_column :coupons, :objectives, :string, array: true
    add_column :coupons, :product_ids, :string, array: true
  end
end
