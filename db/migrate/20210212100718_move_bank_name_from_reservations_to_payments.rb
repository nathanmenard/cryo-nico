class MoveBankNameFromReservationsToPayments < ActiveRecord::Migration[6.0]
  def change
    remove_column :reservations, :bank_name
    add_column :payments, :bank_name, :string
  end
end
