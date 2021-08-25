class MakeTransactionIdNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :payments, :transaction_id, true
  end
end
