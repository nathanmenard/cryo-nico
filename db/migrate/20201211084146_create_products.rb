class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :duration, null: false
      t.references :room, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
