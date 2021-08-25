class AddCanceledToReservations < ActiveRecord::Migration[6.0]
  def change
    add_column :reservations, :canceled, :boolean, null: false, default: false
    add_column :reservations, :cancelation_reason, :text
    add_column :reservations, :refunded, :boolean, null: false, default: false
  end
end
