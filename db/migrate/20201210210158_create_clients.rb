class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.boolean :male, null: false
      t.string :birth_date, null: false
      t.references :franchise, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
