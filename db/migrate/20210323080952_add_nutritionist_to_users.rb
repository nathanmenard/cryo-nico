class AddNutritionistToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :nutritionist, :boolean, null: false, default: :false
  end
end
