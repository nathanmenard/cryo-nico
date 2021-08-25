class CreateCompanyClients < ActiveRecord::Migration[6.0]
  def change
    create_table :company_clients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :job
      t.string :phone
      t.references :company, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
