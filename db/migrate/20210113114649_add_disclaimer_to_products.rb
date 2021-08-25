class AddDisclaimerToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :disclaimer, :text
  end
end
