class MoveAllPaymentsRelatedToPayments < ActiveRecord::Migration[6.0]
  def change
    remove_column :reservations, :transaction_id
    remove_column :reservations, :paid
    remove_column :reservations, :coupon_id
    remove_column :reservations, :amount
    add_column :payments, :transaction_id, :string, null: false, index: { unique: true }
    add_reference :payments, :coupon, null: true, index: true, foreign_key: true
  end
end
