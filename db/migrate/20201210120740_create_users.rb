class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.references :franchise, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
