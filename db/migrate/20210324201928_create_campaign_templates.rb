class CreateCampaignTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :campaign_templates do |t|
      t.references :franchise, null: false, index: true, foreign_key: true
      t.integer :external_id, null: false, index: { unique: true }
      t.text :name, null: false
      t.text :subject, null: false

      t.timestamps
    end
  end
end
