class CreateCouponsFranchises < ActiveRecord::Migration[6.0]
  def change
    create_table :coupons_franchises do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :franchise, null: false, foreign_key: true

      t.timestamps
    end
    add_index :coupons_franchises, [:coupon_id, :franchise_id], unique: true
  end
end
