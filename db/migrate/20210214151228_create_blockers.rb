class CreateBlockers < ActiveRecord::Migration[6.0]
  def change
    create_table :blockers do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.text :notes, null: false
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
