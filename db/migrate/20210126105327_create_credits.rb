class CreateCredits < ActiveRecord::Migration[6.0]
  def change
    create_table :credits do |t|
      t.references :client, null: false, index: true, foreign_key: true
      t.references :product, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
