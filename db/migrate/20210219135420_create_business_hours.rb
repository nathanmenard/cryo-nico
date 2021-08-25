class CreateBusinessHours < ActiveRecord::Migration[6.0]
  def change
    create_table :business_hours do |t|
      t.references :franchise, null: false, index: true, foreign_key: true
      t.string :day, null: false
      t.time :morning_start_time, null: false
      t.time :morning_end_time, null: false
      t.time :afternoon_start_time, null: false
      t.time :afternoon_end_time, null: false

      t.timestamps
    end
  end
end
