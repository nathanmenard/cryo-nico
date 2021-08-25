class MoveTransactionsDataToReservations < ActiveRecord::Migration[6.0]
  def change
    add_column :reservations, :transaction_id, :string, null: false, index: { unique: true }
    add_column :reservations, :amount, :integer, null: false
    add_column :reservations, :bank_name, :string
    add_column :reservations, :paid, :boolean
  end
end
