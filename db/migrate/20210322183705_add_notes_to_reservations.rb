class AddNotesToReservations < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :notes, :text
  end
end
