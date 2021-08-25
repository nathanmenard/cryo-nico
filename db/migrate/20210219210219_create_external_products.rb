class CreateExternalProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :external_products do |t|
      t.references :franchise, null: false, index: true, foreign_key: false
      t.string :name, null: false
      t.integer :amount, null: false
      t.float :tax, null: false

      t.timestamps
    end
  end
end
