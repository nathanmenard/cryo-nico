class RemoveProductIdFromReservations < ActiveRecord::Migration[6.0]
  def change
    remove_column :reservations, :product_id
  end
end
