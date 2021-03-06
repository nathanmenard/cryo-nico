class CreateRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.integer :capacity, null: false
      t.references :franchise, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
