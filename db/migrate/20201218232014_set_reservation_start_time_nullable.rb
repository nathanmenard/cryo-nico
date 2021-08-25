class SetReservationStartTimeNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :reservations, :start_time, true
  end
end
