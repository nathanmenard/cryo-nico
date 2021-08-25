class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.text :body, null: false
      t.boolean :published
      t.references :product, null: false, index: true, foreign_key: true
      t.references :client, null: true, index: true, foreign_key: true
      t.references :company_client, null: true, index: true, foreign_key: true

      t.timestamps
    end
  end
end
