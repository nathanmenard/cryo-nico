class AddIbanToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :iban, :string
  end
end
