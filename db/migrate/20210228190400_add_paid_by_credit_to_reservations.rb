class AddPaidByCreditToReservations < ActiveRecord::Migration[6.0]
  def change
    add_column :reservations, :paid_by_credit, :boolean, null: false, default: false
  end
end
