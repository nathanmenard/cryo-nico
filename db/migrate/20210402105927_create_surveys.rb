class CreateSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :surveys do |t|
      t.references :product, null: false, index: true, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
