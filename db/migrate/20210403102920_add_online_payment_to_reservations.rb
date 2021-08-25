class AddOnlinePaymentToReservations < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :to_be_paid_online, :boolean, null: false
  end
end
