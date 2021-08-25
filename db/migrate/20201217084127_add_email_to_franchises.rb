class AddEmailToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :email, :string
  end
end
