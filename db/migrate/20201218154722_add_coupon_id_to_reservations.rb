class AddCouponIdToReservations < ActiveRecord::Migration[6.0]
  def change
    add_reference :reservations, :coupon, null: true, index: true, foreign_key: true
  end
end
