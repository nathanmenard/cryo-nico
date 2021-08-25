class CreateReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations do |t|
      t.datetime :start_time, null: false
      t.boolean :email_notification, null: false
      t.boolean :first_time, null: false
      t.references :client, null: false, index: true, foreign_key: true
      t.references :product, null: false, index: true, foreign_key: true
      t.references :product_price, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
