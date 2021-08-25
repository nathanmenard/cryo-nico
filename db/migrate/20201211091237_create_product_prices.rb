class CreateProductPrices < ActiveRecord::Migration[6.0]
  def change
    create_table :product_prices do |t|
      t.integer :session_count, null: false
      t.integer :total, null: false
      t.boolean :professionnal, null: false
      t.references :product, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
