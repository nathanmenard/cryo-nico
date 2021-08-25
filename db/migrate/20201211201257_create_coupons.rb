class CreateCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :coupons do |t|
      t.string :name, null: false
      t.integer :value, null: false
      t.string :code, null: false
      t.boolean :percentage, null: false
      t.date :start_date
      t.date :end_date
      t.integer :usage_limit
      t.integer :usage_limit_per_person
      t.references :franchise, null: false, index: true, foreign_key: true

      t.timestamps
    end
    add_index :coupons, [:franchise_id, :code], unique: true
  end
end
