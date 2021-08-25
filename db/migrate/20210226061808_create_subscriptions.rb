class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :subscription_plan, null: false, index: true, foreign_key: true
      t.references :client, null: false, index: true, foreign_key: true
      t.string :external_id, null: false, unique: true
      t.string :status, null: false

      t.timestamps
    end
    add_index :subscriptions, [:subscription_plan_id, :client_id], unique: true
  end
end
