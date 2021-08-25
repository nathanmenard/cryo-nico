class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.text :address, null: false
      t.string :zip_code, null: false
      t.string :city, null: false
      t.string :siret, null: false
      t.text :comment
      t.references :franchise, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
