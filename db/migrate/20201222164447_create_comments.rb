class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :client, null: false, index: true, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
