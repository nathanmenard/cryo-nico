class AddNullableToCoupons < ActiveRecord::Migration[6.0]
  def change
    change_column_null :coupons, :franchise_id, true
  end
end
