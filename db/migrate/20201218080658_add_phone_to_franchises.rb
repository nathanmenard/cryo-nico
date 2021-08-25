class AddPhoneToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :phone, :string
  end
end
