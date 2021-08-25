class AddCompanyClientIdToReservations < ActiveRecord::Migration[6.0]
  def change
    add_reference :reservations, :company_client, null: true, index: true, foreign_key: true
    change_column_null :reservations, :client_id, true
  end
end
