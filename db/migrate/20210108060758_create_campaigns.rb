class CreateCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.text :body, null: false
      t.string :recipients, array: true
      t.boolean :sms, null: false
      t.boolean :draft, null: false, default: true
      t.references :franchise, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
