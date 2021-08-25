class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.references :client, null: true, index: true, foreign_key: true
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
