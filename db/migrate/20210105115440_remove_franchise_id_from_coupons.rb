class RemoveFranchiseIdFromCoupons < ActiveRecord::Migration[6.0]
  def change
    remove_column :coupons, :franchise_id, :integer
  end
end
