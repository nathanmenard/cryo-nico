class CreateSubscriptionPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_plans do |t|
      t.references :product, null: false, index: true, foreign_key: true
      t.integer :session_count, null: false
      t.float :total, null: false

      t.timestamps
    end
  end
end
