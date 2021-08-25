class DropTableTransactions < ActiveRecord::Migration[6.0]
  def change
    drop_table :transactions if table_exists?(:transactions)
  end
end
